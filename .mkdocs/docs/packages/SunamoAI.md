# SunamoAI

Utils for using various AI models with various approach

- **NuGet**: [$(@{Name=SunamoAI; CsprojRel=SunamoAI/SunamoAI/SunamoAI.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAI\README.md; Description=Utils for using various AI models with various approach; ApiNamespace=SunamoAI}.Name)](https://www.nuget.org/packages/SunamoAI)
- **Source**: [GitHub](https://github.com/sunamo/SunamoAI)
- **API reference**: [../../api/SunamoAI.html](../../api/SunamoAI.html)

---
Generic AI services library for calling various AI models (Claude and Gemini) with built-in retry logic and rate limit handling.

## Overview

SunamoAI provides a clean, consistent interface for interacting with multiple AI APIs. It handles common concerns like rate limiting, retries, and error handling, allowing you to focus on your business logic rather than API integration details.

## Features

- **Claude API Support** - Direct HTTP API integration with Anthropic's Claude
- **Claude CLI Support** - Integration with Claude command-line interface with automatic retry logic
- **Gemini API Support** - Google Gemini AI integration
- **Rate Limit Handling** - Automatic detection and retry with exponential backoff
- **Configurable Logging** - Multiple logging levels (basic, verbose, detailed)
- **Async/Await** - Fully asynchronous API for modern .NET applications

## Main Components

### ClaudeApiService
Service for calling Claude via Anthropic's HTTP API.

```csharp
var service = new ClaudeApiService(logger, apiKey, isVerboseLoggingEnabled: true);
var response = await service.CallClaudeApi(
    prompt: "Explain quantum computing",
    model: "claude-sonnet-4-20250514",
    maxTokens: 1024,
    temperature: 0.0
);
```

**Key Methods:**
- `CallClaudeApi(prompt, model, maxTokens, temperature)` - Sends a prompt to Claude and returns the response

### ClaudeCliService
Service for calling Claude via command-line interface (claude.cmd).

```csharp
var service = new ClaudeCliService(logger, isVerboseLoggingEnabled: true);
var response = await service.CallClaudeCli(prompt: "Write a haiku about coding");
```

**Features:**
- Automatic rate limit detection and retry (up to 3 attempts)
- 65-second wait between retries with countdown display
- Stdin-based prompt passing to avoid escaping issues

**Key Methods:**
- `CallClaudeCli(prompt, retryCount)` - Calls Claude CLI with automatic retry logic

### GeminiApiService
Service for calling Google's Gemini AI API.

```csharp
var service = new GeminiApiService(logger, apiKey, isBasicLoggingEnabled: true);
var response = await service.CallGeminiApi(
    prompt: "What is the capital of France?",
    model: "gemini-2.5-flash",
    temperature: 0.0f,
    maxOutputTokens: 8192
);
```

**Key Methods:**
- `CallGeminiApi(prompt, model, temperature, maxOutputTokens)` - Sends a prompt to Gemini and returns the response

## Installation

```bash
dotnet add package SunamoAI
```

## Dependencies

- **Mscc.GenerativeAI** (v2.8.0) - Gemini API client
- **Microsoft.Extensions.Logging.Abstractions** - Logging infrastructure
- **.NET 10.0 / .NET 9.0 / .NET 8.0** target frameworks

## Usage Example

```csharp
using SunamoAI;
using Microsoft.Extensions.Logging;

// Setup logger
var logger = LoggerFactory.Create(builder => builder.AddConsole()).CreateLogger("AI");

// Use Claude API
var claudeApi = new ClaudeApiService(logger, "your-api-key");
var claudeResponse = await claudeApi.CallClaudeApi("Explain AI in simple terms");

// Use Claude CLI
var claudeCli = new ClaudeCliService(logger, isVerboseLoggingEnabled: true);
var cliResponse = await claudeCli.CallClaudeCli("Write a short poem");

// Use Gemini
var gemini = new GeminiApiService(logger, "your-gemini-api-key");
var geminiResponse = await gemini.CallGeminiApi("What is machine learning?");
```

## Architecture Pattern

SunamoAI is designed to contain **only generic AI services**. Domain-specific logic should be implemented in your application layer:

```
SunamoAI (generic AI services)
    ↓ used by
Your Application (business logic)
    - Build domain-specific prompts
    - Call SunamoAI services
    - Parse domain-specific responses
```

## Logging Levels

All services support multiple logging levels:

- **Basic Logging** - Essential operations and warnings
- **Verbose Logging** - Request/response sizes and timing
- **Detailed Logging** - Full debugging information including API responses

## Error Handling

All services return `null` on failure and log errors appropriately. The ClaudeCliService includes special handling for rate limits:

- Detects rate limit errors automatically
- Retries up to 3 times with 65-second delays
- Displays countdown during wait periods
- Exits gracefully if all retries fail

## Package Information

- **Package Name**: SunamoAI
- **Category**: Platform-Independent NuGet Package
- **Target Frameworks**: .NET 10.0, .NET 9.0, .NET 8.0

## Related Packages

This package is part of the Sunamo package ecosystem, designed to provide modular, platform-independent utilities for .NET development.

## License

See the repository root for license information.

