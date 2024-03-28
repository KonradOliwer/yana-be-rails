# Yet another notes app
___
This is learning project. So take everything with grain of salt and don't emulate things without a thought.

This is [ruby](https://www.ruby-lang.org/en/) + [Rails](https://rubyonrails.org/) implementation of backend
For more details about project read frontend [README.md](https://github.com/KonradOliwer/yana-fe-react/)

This app is not production ready, as it has no production configuration.

## Using app
### Requirements
- [ruby](https://www.ruby-lang.org/en/)
- [rails](https://rubyonrails.org/)
- [docker](https://www.docker.com/)

### Running the app

Install dependencies
```bash
gem install bundler
bundle install
```

Start db (this will drop DB on finishing process)
```bash
docker run --name postgres -e POSTGRES_PASSWORD=password -e POSTGRES_USER=user -e POSTGRES_DB=yana -p 5432:5432 --rm postgres
```

Run migration:
```bash
bin/rails db:migrate
```

Run the app
```bash
bin/rails server
```