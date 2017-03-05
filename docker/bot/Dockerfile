FROM ruby:2.3.3

RUN gem install rack
RUN gem install facebook-messenger
RUN gem install dotenv
RUN gem install rerun
RUN gem install redis
RUN gem install state_machines
RUN gem install sqlite3
RUN gem install wit
RUN gem install twitter


WORKDIR /usr/src/app

COPY . .

EXPOSE 3000

CMD ["rackup", "-p", "3000", "-o", "0.0.0.0"]
