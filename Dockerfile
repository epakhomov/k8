FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine as build

WORKDIR /App
COPY *.csproj ./
COPY ./ ./

ARG CONTRAST_AGENT_VERSION=1.5.0
RUN dotnet add package Contrast.SensorsNetCore --version ${CONTRAST_AGENT_VERSION}
RUN dotnet publish -c Release -o out

#####
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /App
COPY bin/Release/netcoreapp3.1/publish /App

# Contrast credentials and config
ARG CONTRAST__API__URL
ARG CONTRAST__API__API_KEY
ARG CONTRAST__API__SERVICE_KEY
ARG CONTRAST__API__USER_NAME
ARG CONTRAST_CONFIG_PATH
ARG CONTRAST__AGENT__LOGGER__LEVEL=TRACE
ARG CORECLR_ENABLE_PROFILING=1

# Additional Contrast config settings (omit if base image)
ARG CONTRAST__APPLICATION__NAME=counter-image
ARG CONTRAST__SERVER__ENVIRONMENT=development

# Set Contrast Environment Variables from ARGS
ENV CONTRAST__API__URL=${CONTRAST__API__URL}
ENV CONTRAST__API__API_KEY=${CONTRAST__API__API_KEY}
ENV CONTRAST__API__SERVICE_KEY=${CONTRAST__API__SERVICE_KEY}
ENV CONTRAST__API__USER_NAME=${CONTRAST__API__USER_NAME}
#ENV CORECLR_PROFILER_PATH_64=contrast/runtimes/win-x64/native/ContrastProfiler.so
#ENV CORECLR_PROFILER_PATH_64=contrast/runtimes/win-x86/native/ContrastProfiler.so
ENV CORECLR_PROFILER_PATH_64=contrast/runtimes/linux-x64/native/ContrastProfiler.so
ENV CORECLR_PROFILER={8B2CE134-0948-48CA-A4B2-80DDAD9F5791}
ENV CORECLR_ENABLE_PROFILING=${CORECLR_ENABLE_PROFILING}
ENV CONTRAST__AGENT__LOGGER__LEVEL=${CONTRAST__AGENT__LOGGER__LEVEL}

# Additional Contrast config settings (omit if base image)
ENV CONTRAST__APPLICATION__NAME=${CONTRAST__APPLICATION__NAME}
ENV CONTRAST__SERVER__ENVIRONMENT=${CONTRAST__SERVER__ENVIRONMENT}
ENTRYPOINT ["dotnet", "NetCore.Docker.dll"]
