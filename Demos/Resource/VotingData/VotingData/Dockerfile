FROM microsoft/windowsservercore:1709 AS base
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -OutFile stateful_aspnetcore_2.0.ps1 https://aka.ms/sfmesh_stateful_aspnetcore_2.0.ps1; .\stateful_aspnetcore_2.0.ps1;
WORKDIR /app
EXPOSE 20004

FROM microsoft/aspnetcore-build:2.0 AS build
WORKDIR /src
COPY VotingData/VotingData.csproj VotingData/
COPY VotingData/Nuget.Config ./
COPY Microsoft.ServiceFabric.Mesh.AspNetCore.Data.1.0.1-beta.nupkg ./
COPY Microsoft.ServiceFabric.Mesh.Data.Collections.Native.1.0.2-beta.nupkg ./
COPY Microsoft.ServiceFabric.Mesh.Data.Collections.1.0.1-beta.nupkg ./
COPY Microsoft.VisualStudio.Azure.SFApp.Targets.1.0.0-preview.5.0.nupkg ./
RUN dotnet restore VotingData/VotingData.csproj
COPY . .
WORKDIR /src/VotingData
RUN dotnet build VotingData.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish VotingData.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "VotingData.dll"]