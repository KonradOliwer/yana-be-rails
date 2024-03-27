require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Note.delete_all
  end

  test "should get index" do
    saved = Note.create(name: "Note 1", content: "Content 1")

    get notes_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_not_nil json_response[0]['id']
    assert_equal saved.name, json_response[0]['name']
    assert_equal saved.content, json_response[0]['content']
  end

  test "should get index even without any notes in db" do
    get notes_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 0, json_response.length
  end

  test "should create note" do
    assert_difference("Note.count") do
      post notes_url, params: { name: "name1", content: "content1" }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['id']
    assert_equal "name1", json_response['name']
    assert_equal "content1", json_response['content']
  end

  test "should fail to create note if name is too long" do
    assert_difference("Note.count", 0) do
      post notes_url, params: { name: "a" * 51, content: "content1" }, as: :json
    end

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "NOTE_VALIDATION_ERROR", json_response['code']
    assert_equal "Validation failed: Name is too long (maximum is 50 characters)", json_response['message']
  end

  test "should update note" do
    post notes_url, params: { name: "name1", content: "content1" }, as: :json
    post_json_response = JSON.parse(response.body)

    put note_url({ noteId: post_json_response['id'] }), params: { id: post_json_response['id'], name: "name2", content: "content2" }, as: :json
    assert_response :success
    put_json_response = JSON.parse(response.body)
    assert_not_nil put_json_response['id']
    assert_equal "name2", put_json_response['name']
    assert_equal "content2", put_json_response['content']

    get notes_url, as: :json
    get_json_response = JSON.parse(response.body)
    assert_not_nil post_json_response['id'], get_json_response[0]['id']
    assert_equal "name2", get_json_response[0]['name']
    assert_equal "content2", get_json_response[0]['content']
  end

  test "should fail update if note id in body is different then in URL" do
    post notes_url, params: { name: "name1", content: "content1" }, as: :json
    post_json_response = JSON.parse(response.body)

    put note_url({ noteId: post_json_response['id'] }), params: { id: SecureRandom.uuid, name: "name2", content: "content2" }, as: :json
    put_json_response = JSON.parse(response.body)
    assert_response :bad_request
    assert_equal "NOTE_VALIDATION_ERROR", put_json_response['code']
    assert_equal "id: should match url id", put_json_response['message']
  end

  test "should fail update if new name is to long" do
    post notes_url, params: { name: "name1", content: "content1" }, as: :json
    post_json_response = JSON.parse(response.body)

    put note_url({ noteId: post_json_response['id'] }), params: { id: post_json_response['id'], name: "a" * 51, content: "content2" }, as: :json
    assert_response :bad_request
    put_json_response = JSON.parse(response.body)
    assert_equal "NOTE_VALIDATION_ERROR", put_json_response['code']
    assert_equal "Validation failed: Name is too long (maximum is 50 characters)", put_json_response['message']
  end

  test "should destroy note" do
    post notes_url, params: { name: "name1", content: "content1" }, as: :json
    post_json_response = JSON.parse(response.body)

    assert_difference("Note.count", -1) do
      delete note_url(post_json_response['id']), as: :json
    end

    assert_response :no_content

    get notes_url, as: :json
    get_json_response = JSON.parse(response.body)
    assert_equal 0, get_json_response.length
  end
end
