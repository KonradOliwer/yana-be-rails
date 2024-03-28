class NotesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: -> { render json: NotesErrorResponse.new(code: NOT_FOUND, message: "Note not found"), status: :not_found }
  rescue_from ActiveRecord::RecordInvalid, with: ->(error) { render json: NotesErrorResponse.new(code: VALIDATION_ERROR, message: error.message), status: :bad_request }
  rescue_from ActiveRecord::RecordNotUnique, with: ->(error) { render json: NotesErrorResponse.new(code: ALREADY_EXISTS, message: nil), status: :bad_request }

  # Error codes
  NOT_FOUND = "NOTE_NOT_FOUND"
  ALREADY_EXISTS = "NOTE_ALREADY_EXISTS"
  VALIDATION_ERROR = "NOTE_VALIDATION_ERROR"
  WRITE_ERROR = "NOTE_WRITE_ERROR"

  def index
    notes = Note.all
    render json: notes
  end

  def create
    note = Note.new(create_note_params)
    note.validate!
    if note.save
      render json: note, status: :created
    else
      logger.error("error on create: #{note.errors.full_messages}")
      render json: NotesErrorResponse.new(code: WRITE_ERROR, message: nil), status: :bad_request
    end
  end

  def update
    if params[:noteId] != params[:id]
      render json: NotesErrorResponse.new(code: VALIDATION_ERROR, message: "id: should match url id"), status: :bad_request
      return
    end
    note = Note.find(params[:noteId])
    note.assign_attributes(note_params)
    note.validate!
    if note.save
      render json: note
    else
      logger.error("error on create: #{note.errors.full_messages}")
      render json: NotesErrorResponse.new(code: WRITE_ERROR, message: nil), status: :bad_request
    end
  end

  def destroy
    note = Note.find(params[:noteId])
    note.destroy!
  end

  # Only allow a list of trusted parameters through.
  def note_params
    params.require(:note).permit(:id, :name, :content)
  end

  def create_note_params
    params.require(:note).permit(:name, :content)
  end
end

NotesErrorResponse = Data.define(:code, :message)