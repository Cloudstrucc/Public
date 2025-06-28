FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["EcommerceBlazor.csproj", "."]
RUN dotnet restore "./EcommerceBlazor.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "EcommerceBlazor.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EcommerceBlazor.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:80/health || exit 1

ENTRYPOINT ["dotnet", "EcommerceBlazor.dll"]
