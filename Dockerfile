FROM node:16.14.2 as build-stage

ARG BACKEND_URL
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN REACT_APP_BACKEND_URL=${BACKEND_URL} npm run build

#

FROM nginx:latest as production-stage

COPY nginx.conf /etc/nginx/conf.d/default.template
COPY --from=build-stage /app/build /usr/share/nginx/html

CMD ["/bin/sh" , "-c" , "envsubst \"`env | awk -F = '{printf \" \\\\$%s\", $1}'`\" < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
