FROM ruby:3.3.1

RUN set -xe && \
  apt-get update -qq && \
  apt-get install -y \
  openssl libssl-dev curl locales-all wget openssh-client \
  build-essential libpq-dev nodejs \
  cmake \
  ca-certificates socat \
  git \
  software-properties-common \
  libreadline-dev

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -qq && apt-get install -y \
  chromium \
  chromium-driver \
  nodejs \
  postgresql-client-12

# Set default working directory
WORKDIR /app
ENV BUNDLE_PATH /bundle_cache

COPY Gemfile* ./
RUN gem install bundler && bundle config set force_ruby_platform false && bundle install --without production

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
