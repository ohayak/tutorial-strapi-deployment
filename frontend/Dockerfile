FROM node:16

RUN yarn global add @strapi/strapi@4.4.3

WORKDIR /opt/website/
COPY ./ ./

ENV PATH=${PWD}/node_modules/.bin:${PATH}
ENV NEXT_PUBLIC_STRAPI_API_URL=http://localhost:1337
RUN yarn config set network-timeout 300000
RUN yarn install

CMD ["yarn", "build:start"]
