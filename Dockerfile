FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /source
COPY . .
RUN dotnet publish src/SmartX.Api/SmartX.Api.csproj -c Release -o /app --no-self-contained /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app .
RUN mkdir -p /app/data && chown -R $APP_UID /app/data
USER $APP_UID
ENV ASPNETCORE_URLS=http://+:8080
ENV SmartX__DataDirectory=/app/data
EXPOSE 8080
ENTRYPOINT ["dotnet", "SmartX.Api.dll", "--urls=http://+:8080"]
