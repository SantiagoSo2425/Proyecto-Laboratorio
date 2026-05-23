FROM ghcr.io/cirruslabs/flutter:3.22.2 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.yaml
RUN flutter pub get

COPY . .

ARG API_BASE_URL
ARG README_API_BASE_URL
RUN flutter build web --release --pwa-strategy=none --dart-define=API_BASE_URL=${API_BASE_URL} --dart-define=README_API_BASE_URL=${README_API_BASE_URL}

FROM nginx:1.25-alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
