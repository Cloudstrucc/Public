FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["EcommerceAPI.csproj", "."]
RUN dotnet restore "./EcommerceAPI.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "EcommerceAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EcommerceAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:80/health || exit 1

ENTRYPOINT ["dotnet", "EcommerceAPI.dll"]
