# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY AspNetCoreVerifiableCredentials.csproj .
RUN dotnet restore

# Copy everything else and build
COPY . .
WORKDIR /src
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

# Copy published app
COPY --from=publish /app/publish .

# Set environment variable for port
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "AspNetCoreVerifiableCredentials.dll"]

