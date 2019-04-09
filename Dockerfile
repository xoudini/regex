FROM swift:latest

WORKDIR /usr/src/regex

COPY . .

CMD [ "bash" ]
