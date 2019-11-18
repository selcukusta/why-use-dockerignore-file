FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine as build-ENV
RUN ["mkdir", "-p", "/usr/local/app"]
COPY /src /build
RUN dotnet publish -c Release -r linux-musl-x64 /build -o /usr/local/app
RUN ["rm", "-rf", "/build"]
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80/TCP
ENTRYPOINT ["./usr/local/app/WhyUseIgnore"]