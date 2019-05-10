FROM swift:latest

WORKDIR /usr/src/regex

RUN apt update && apt install -y time

COPY . .

CMD [ "bash" ]
