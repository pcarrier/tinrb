FROM ubuntu:trusty
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get install -y ruby2.1
RUN gem --version
RUN gem update --system
RUN gem install bundler
ADD Gemfile /app/Gemfile
RUN cd /app && bundler install
WORKDIR /app
ADD . /app

CMD ["/usr/local/bin/unicorn", "-c", "unicorn.rb"]
