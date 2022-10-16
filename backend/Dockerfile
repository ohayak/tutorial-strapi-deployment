FROM node:16 AS base

RUN yarn global add @strapi/strapi@4.4.3

WORKDIR /opt/strapi/
COPY ./ ./

ENV PATH=${PWD}/node_modules/.bin:${PATH}
RUN yarn config set network-timeout 300000
RUN yarn install --prod

ENV NODE_ENV=production
CMD ["yarn", "build:start"]
