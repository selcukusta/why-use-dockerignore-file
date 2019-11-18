FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine as build-ENV
COPY /src /build
WORKDIR /build
RUN dotnet publish -c Release -r linux-musl-x64 -o publish-folder
FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0-alpine as runtime
COPY --from=build-env /build/publish-folder /usr/local/app
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80/TCP
ENTRYPOINT ["./usr/local/app/WhyUseIgnore"]