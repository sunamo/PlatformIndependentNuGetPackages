const fs = require('fs');
const path = require('path');

// Package mapping - maps package names to their alternative NuGet packages
const packageAlternatives = {
  SunamoAI: {
    description: 'AI and language model integration functionality',
    alternatives: [
      { name: 'Microsoft.SemanticKernel', nuget: 'Microsoft.SemanticKernel', purpose: 'AI orchestration framework from Microsoft for integrating LLMs', features: 'Prompt templating, function calling, memory, connectors for OpenAI/Azure OpenAI' },
      { name: 'LangChain', nuget: 'LangChain', purpose: 'Popular framework for building applications with large language models', features: 'Chain composition, agents, memory, vector stores' },
      { name: 'Betalgo.OpenAI', nuget: 'Betalgo.OpenAI', purpose: 'OpenAI API client for .NET', features: 'ChatGPT, GPT-4, embeddings, function calling support' },
      { name: 'Azure.AI.OpenAI', nuget: 'Azure.AI.OpenAI', purpose: 'Official Azure OpenAI SDK', features: 'Enterprise-grade AI integration with Azure services' },
      { name: 'ML.NET', nuget: 'Microsoft.ML', purpose: 'Microsoft machine learning framework for .NET', features: 'Custom ML models, classification, regression, anomaly detection' }
    ],
    comparison: 'These alternatives provide production-ready AI integration with extensive community support and regular updates.'
  },

  SunamoArgs: {
    description: 'Command-line argument parsing',
    alternatives: [
      { name: 'CommandLineParser', nuget: 'CommandLineParser', purpose: 'Industry-standard command-line parsing library', features: 'Strong typing, automatic help generation, verb support' },
      { name: 'System.CommandLine', nuget: 'System.CommandLine', purpose: 'Microsoft official command-line API', features: 'Modern API, tab completion, suggestion, middleware pipeline' },
      { name: 'McMaster.Extensions.CommandLineUtils', nuget: 'McMaster.Extensions.CommandLineUtils', purpose: 'Feature-rich command-line parser', features: 'Attributes-based parsing, dependency injection, interactive prompts' },
      { name: 'Clipr', nuget: 'clipr', purpose: 'Simple command-line parser', features: 'Attribute-driven, fluent API, automatic validation' }
    ],
    comparison: 'These alternatives provide robust argument parsing with better validation and help generation.'
  },

  SunamoAsync: {
    description: 'Asynchronous programming utilities',
    alternatives: [
      { name: 'Nito.AsyncEx', nuget: 'Nito.AsyncEx', purpose: 'Comprehensive async/await helpers library', features: 'AsyncLock, AsyncCollection, async-compatible events, task utilities' },
      { name: 'Polly', nuget: 'Polly', purpose: 'Resilience and transient fault handling', features: 'Retry, circuit breaker, timeout, bulkhead isolation policies' },
      { name: 'System.Threading.Tasks.Dataflow', nuget: 'System.Threading.Tasks.Dataflow', purpose: 'Task parallel library dataflow components', features: 'Actor-based concurrent programming, data pipelines' },
      { name: 'AsyncEnumerator', nuget: 'AsyncEnumerator', purpose: 'Async enumeration support', features: 'IAsyncEnumerable implementation, async LINQ' }
    ],
    comparison: 'Built-in async/await in modern .NET combined with these libraries covers most async scenarios.'
  },

  SunamoAttributes: {
    description: 'Custom attributes and attribute-related utilities',
    alternatives: [
      { name: 'System.Reflection', nuget: 'System.Reflection', purpose: 'Built-in .NET reflection capabilities', features: 'Attribute reading, type inspection, metadata access' },
      { name: 'Fody', nuget: 'Fody', purpose: 'IL weaving tool for code generation via attributes', features: 'Compile-time code injection, property change notification' },
      { name: 'PostSharp', nuget: 'PostSharp', purpose: 'Aspect-oriented programming with attributes', features: 'Cross-cutting concerns, caching, logging via attributes' }
    ],
    comparison: 'Most attribute functionality is available in System.Reflection. Fody/PostSharp add compile-time capabilities.'
  },

  SunamoAzureDevOpsApi: {
    description: 'Azure DevOps API integration',
    alternatives: [
      { name: 'Microsoft.TeamFoundationServer.Client', nuget: 'Microsoft.TeamFoundationServer.Client', purpose: 'Official Azure DevOps client library', features: 'Work items, build, release, git operations' },
      { name: 'Microsoft.VisualStudio.Services.Client', nuget: 'Microsoft.VisualStudio.Services.Client', purpose: 'Visual Studio Team Services client', features: 'REST API wrapper, authentication, service clients' },
      { name: 'Azure.DevOps', nuget: 'Microsoft.TeamFoundation.DistributedTask.WebApi', purpose: 'Task and pipeline APIs', features: 'Pipeline management, task execution' }
    ],
    comparison: 'Official Microsoft libraries provide complete Azure DevOps API coverage with regular updates.'
  },

  SunamoBazosCrawler: {
    description: 'Web scraping for Bazos marketplace',
    alternatives: [
      { name: 'HtmlAgilityPack', nuget: 'HtmlAgilityPack', purpose: 'HTML parsing and DOM manipulation', features: 'XPath queries, LINQ to HTML, robust HTML parsing' },
      { name: 'AngleSharp', nuget: 'AngleSharp', purpose: 'Modern HTML/CSS parser', features: 'Standards-compliant, CSS selectors, DOM API' },
      { name: 'ScrapySharp', nuget: 'ScrapySharp', purpose: 'Web scraping framework', features: 'CSS selectors, form submission, navigation' },
      { name: 'Selenium.WebDriver', nuget: 'Selenium.WebDriver', purpose: 'Browser automation for dynamic content', features: 'JavaScript rendering, interaction with dynamic pages' }
    ],
    comparison: 'For static content use HtmlAgilityPack/AngleSharp. For JavaScript-heavy sites use Selenium/Playwright.'
  },

  SunamoBts: {
    description: 'Bug tracking system utilities',
    alternatives: [
      { name: 'Octokit', nuget: 'Octokit', purpose: 'GitHub API client', features: 'Issues, pull requests, repositories management' },
      { name: 'Atlassian.SDK', nuget: 'Atlassian.SDK', purpose: 'Jira and Confluence integration', features: 'Issue tracking, project management' },
      { name: 'Microsoft.TeamFoundationServer.Client', nuget: 'Microsoft.TeamFoundationServer.Client', purpose: 'Azure DevOps work items', features: 'Work item tracking, queries, updates' }
    ],
    comparison: 'Choose based on your bug tracking platform (GitHub, Jira, Azure DevOps).'
  },

  SunamoChar: {
    description: 'Character manipulation utilities',
    alternatives: [
      { name: 'System.Char', nuget: 'System.Runtime', purpose: 'Built-in .NET character methods', features: 'IsDigit, IsLetter, ToUpper, ToLower, Unicode support' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'String and character humanization', features: 'Pluralization, casing, number to words conversion' }
    ],
    comparison: 'Most character operations are well-covered by built-in System.Char methods.'
  },

  SunamoCl: {
    description: 'Command-line interface utilities',
    alternatives: [
      { name: 'Spectre.Console', nuget: 'Spectre.Console', purpose: 'Modern console UI library', features: 'Tables, progress bars, colors, prompts, markup rendering' },
      { name: 'ConsoleTables', nuget: 'ConsoleTables', purpose: 'Table rendering in console', features: 'Automatic column sizing, borders, alignment' },
      { name: 'Colorful.Console', nuget: 'Colorful.Console', purpose: 'Colored console output', features: 'ASCII art, gradients, styled text' },
      { name: 'ShellProgressBar', nuget: 'ShellProgressBar', purpose: 'Console progress bars', features: 'Nested progress bars, percentage display' }
    ],
    comparison: 'Spectre.Console is the most comprehensive modern solution for rich console applications.'
  },

  SunamoClearScript: {
    description: 'JavaScript engine integration',
    alternatives: [
      { name: 'Microsoft.ClearScript.V8', nuget: 'Microsoft.ClearScript.V8', purpose: 'V8 JavaScript engine for .NET', features: 'Execute JavaScript, interop with .NET objects' },
      { name: 'Jint', nuget: 'Jint', purpose: 'Pure .NET JavaScript interpreter', features: 'ECMAScript 5.1 support, no native dependencies' },
      { name: 'Jurassic', nuget: 'Jurassic', purpose: 'JavaScript compiler and runtime', features: 'IL compilation, performance optimizations' }
    ],
    comparison: 'ClearScript offers V8 engine. Jint is pure .NET. Choose based on performance vs portability needs.'
  },

  SunamoClipboard: {
    description: 'Clipboard operations',
    alternatives: [
      { name: 'System.Windows.Forms.Clipboard', nuget: 'System.Windows.Forms', purpose: 'Windows Forms clipboard API', features: 'Text, images, custom formats' },
      { name: 'TextCopy', nuget: 'TextCopy', purpose: 'Cross-platform clipboard library', features: 'Works on Windows, Linux, macOS' },
      { name: 'Clipboard.Net', nuget: 'Clipboard.Net', purpose: 'Multi-format clipboard support', features: 'Images, files, HTML, custom data' }
    ],
    comparison: 'Use TextCopy for cross-platform. System.Windows.Forms for Windows-only applications.'
  },

  SunamoCollectionOnDrive: {
    description: 'Persistent collections stored on disk',
    alternatives: [
      { name: 'LiteDB', nuget: 'LiteDB', purpose: 'NoSQL embedded database', features: 'Document storage, LINQ queries, single file database' },
      { name: 'Realm', nuget: 'Realm', purpose: 'Mobile database', features: 'Object persistence, reactive programming, cross-platform' },
      { name: 'SQLite-net', nuget: 'sqlite-net-pcl', purpose: 'SQLite ORM', features: 'Lightweight, LINQ support, cross-platform' },
      { name: 'Akavache', nuget: 'Akavache', purpose: 'Asynchronous key-value store', features: 'Reactive extensions, SQLite backend, caching' }
    ],
    comparison: 'LiteDB offers document storage. SQLite for relational. Akavache for key-value caching.'
  },

  SunamoCollectionWithoutDuplicates: {
    description: 'Collections that prevent duplicate entries',
    alternatives: [
      { name: 'System.Collections.Generic.HashSet', nuget: 'System.Collections', purpose: 'Built-in set implementation', features: 'O(1) lookups, automatic deduplication' },
      { name: 'System.Collections.Concurrent.ConcurrentBag', nuget: 'System.Collections.Concurrent', purpose: 'Thread-safe collection', features: 'Concurrent access, unordered collection' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'LINQ extensions including DistinctBy', features: 'Advanced LINQ operations, custom equality comparers' }
    ],
    comparison: 'HashSet<T> is the standard .NET approach for duplicate-free collections.'
  },

  SunamoCollections: {
    description: 'Collection utilities and extensions',
    alternatives: [
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Extended LINQ operations', features: 'Batch, DistinctBy, MaxBy, Windowed, 50+ operators' },
      { name: 'System.Linq.Async', nuget: 'System.Linq.Async', purpose: 'Async LINQ operations', features: 'IAsyncEnumerable support, async query operators' },
      { name: 'NetFabric.Hyperlinq', nuget: 'NetFabric.Hyperlinq', purpose: 'High-performance LINQ', features: 'Zero-allocation, optimized enumerators' },
      { name: 'SuperLinq', nuget: 'SuperLinq', purpose: 'Advanced LINQ extensions', features: 'Additional operators, performance improvements' }
    ],
    comparison: 'MoreLINQ is the most popular for general collection extensions. SuperLinq is its modern successor.'
  },

  SunamoCollectionsChangeContent: {
    description: 'Collection modification utilities',
    alternatives: [
      { name: 'System.Collections.Immutable', nuget: 'System.Collections.Immutable', purpose: 'Immutable collection types', features: 'Thread-safe, builder pattern, structural sharing' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'LINQ extensions for transformations', features: 'Pipe, Concat, Replace operations' },
      { name: 'FluentCollections', nuget: 'FluentCollections', purpose: 'Fluent API for collections', features: 'Method chaining, readable transformations' }
    ],
    comparison: 'Built-in List<T> methods combined with LINQ cover most modification scenarios.'
  },

  SunamoCollectionsGeneric: {
    description: 'Generic collection utilities',
    alternatives: [
      { name: 'System.Collections.Generic', nuget: 'System.Collections', purpose: 'Built-in generic collections', features: 'List, Dictionary, HashSet, Queue, Stack' },
      { name: 'C5', nuget: 'C5', purpose: 'Extended collection library', features: 'Priority queues, interval heaps, sorted dictionaries' },
      { name: 'PowerCollections', nuget: 'XAct.Wintellect.PowerCollections', purpose: 'Advanced data structures', features: 'Bags, ordered dictionaries, deques' }
    ],
    comparison: 'System.Collections.Generic covers 90% of needs. C5 for specialized data structures.'
  },

  SunamoCollectionsIndexesWithNull: {
    description: 'Collections with nullable index support',
    alternatives: [
      { name: 'System.Collections.Generic.Dictionary', nuget: 'System.Collections', purpose: 'Key-value pairs with null support', features: 'Nullable keys/values, O(1) lookup' },
      { name: 'LanguageExt', nuget: 'LanguageExt.Core', purpose: 'Functional programming library', features: 'Option<T> for null safety, functional collections' },
      { name: 'System.Nullable', nuget: 'System.Runtime', purpose: 'Built-in nullable types', features: 'Nullable value types, null-coalescing operators' }
    ],
    comparison: 'Modern C# nullable reference types combined with Dictionary<TKey?, TValue?> handle most cases.'
  },

  SunamoCollectionsNonGeneric: {
    description: 'Non-generic collection utilities',
    alternatives: [
      { name: 'System.Collections', nuget: 'System.Collections.NonGeneric', purpose: 'Built-in non-generic collections', features: 'ArrayList, Hashtable, Queue, Stack' },
      { name: 'System.Collections.Specialized', nuget: 'System.Collections.Specialized', purpose: 'Specialized collections', features: 'NameValueCollection, StringCollection, BitVector32' }
    ],
    comparison: 'Non-generic collections are legacy. Prefer generic collections (List<T>, Dictionary<K,V>) for new code.'
  },

  SunamoCollectionsTo: {
    description: 'Collection conversion utilities',
    alternatives: [
      { name: 'System.Linq', nuget: 'System.Linq', purpose: 'LINQ conversion operators', features: 'ToList, ToArray, ToDictionary, ToHashSet, ToLookup' },
      { name: 'AutoMapper', nuget: 'AutoMapper', purpose: 'Object-to-object mapping', features: 'Collection projection, type conversion' },
      { name: 'Mapster', nuget: 'Mapster', purpose: 'Fast object mapper', features: 'Collection mapping, performance optimized' }
    ],
    comparison: 'LINQ built-in operators handle most collection conversions efficiently.'
  },

  SunamoCollectionsValuesTableGrid: {
    description: 'Table/grid data structure utilities',
    alternatives: [
      { name: 'System.Data.DataTable', nuget: 'System.Data.Common', purpose: 'Built-in table structure', features: 'Rows, columns, constraints, relations' },
      { name: 'CsvHelper', nuget: 'CsvHelper', purpose: 'CSV reading/writing', features: 'Type conversion, configuration, streaming' },
      { name: 'EPPlus', nuget: 'EPPlus', purpose: 'Excel file manipulation', features: 'Read/write Excel, formulas, styling' },
      { name: 'ClosedXML', nuget: 'ClosedXML', purpose: 'Excel library', features: 'Fluent API, tables, ranges, formatting' }
    ],
    comparison: 'DataTable for in-memory tables. EPPlus/ClosedXML for Excel. CsvHelper for CSV.'
  },

  SunamoColors: {
    description: 'Color manipulation utilities',
    alternatives: [
      { name: 'System.Drawing.Color', nuget: 'System.Drawing.Primitives', purpose: 'Built-in color structure', features: 'RGB, ARGB, named colors, conversions' },
      { name: 'SixLabors.ImageSharp', nuget: 'SixLabors.ImageSharp', purpose: 'Modern image processing', features: 'Color spaces, manipulation, cross-platform' },
      { name: 'ColorMine', nuget: 'ColorMine', purpose: 'Color space conversions', features: 'Lab, HSL, HSV, color difference algorithms' },
      { name: 'Colourful', nuget: 'Colourful', purpose: 'Advanced color library', features: 'Multiple color spaces, chromatic adaptation' }
    ],
    comparison: 'System.Drawing.Color for basic needs. ColorMine/Colourful for advanced color science.'
  },

  SunamoCompare: {
    description: 'Comparison utilities',
    alternatives: [
      { name: 'System.Collections.Generic.Comparer', nuget: 'System.Collections', purpose: 'Built-in comparison infrastructure', features: 'IComparer<T>, IEqualityComparer<T>, custom comparers' },
      { name: 'CompareNETObjects', nuget: 'CompareNETObjects', purpose: 'Deep object comparison', features: 'Property comparison, difference reporting, custom comparisons' },
      { name: 'FluentAssertions', nuget: 'FluentAssertions', purpose: 'Assertion library with comparisons', features: 'Object equivalency, collection comparison' }
    ],
    comparison: 'Built-in comparers for simple cases. CompareNETObjects for complex object graphs.'
  },

  SunamoConverters: {
    description: 'Type conversion utilities',
    alternatives: [
      { name: 'System.Convert', nuget: 'System.Runtime', purpose: 'Built-in type conversions', features: 'Primitive type conversions, base64, IConvertible' },
      { name: 'AutoMapper', nuget: 'AutoMapper', purpose: 'Object-to-object mapping', features: 'Convention-based mapping, custom converters' },
      { name: 'Mapster', nuget: 'Mapster', purpose: 'High-performance mapper', features: 'Fast type conversion, code generation' },
      { name: 'ValueOf', nuget: 'ValueOf', purpose: 'Value object creation', features: 'Type-safe value wrappers, implicit conversions' }
    ],
    comparison: 'System.Convert for primitives. AutoMapper/Mapster for complex object conversions.'
  },

  SunamoCrypt: {
    description: 'Cryptography utilities',
    alternatives: [
      { name: 'System.Security.Cryptography', nuget: 'System.Security.Cryptography', purpose: 'Built-in cryptography APIs', features: 'AES, RSA, SHA, HMAC, secure random' },
      { name: 'BouncyCastle', nuget: 'BouncyCastle.Cryptography', purpose: 'Comprehensive crypto library', features: 'Wide algorithm support, X.509, OpenPGP' },
      { name: 'NaCl.Net', nuget: 'NaCl.Core', purpose: 'Modern cryptography', features: 'Authenticated encryption, key exchange, signatures' },
      { name: 'libsodium', nuget: 'Sodium.Core', purpose: 'Easy-to-use crypto library', features: 'High-level API, secure by default' }
    ],
    comparison: 'System.Security.Cryptography for standard algorithms. Sodium for modern best practices.'
  },

  SunamoCsproj: {
    description: 'C# project file manipulation',
    alternatives: [
      { name: 'Microsoft.Build', nuget: 'Microsoft.Build', purpose: 'MSBuild API', features: 'Project loading, evaluation, building' },
      { name: 'Buildalyzer', nuget: 'Buildalyzer', purpose: 'MSBuild project analyzer', features: 'Parse projects, get references, analyze builds' },
      { name: 'Microsoft.CodeAnalysis.Workspaces', nuget: 'Microsoft.CodeAnalysis.Workspaces.MSBuild', purpose: 'Roslyn workspace API', features: 'Solution/project loading, semantic analysis' },
      { name: 'NuGet.ProjectModel', nuget: 'NuGet.ProjectModel', purpose: 'NuGet project operations', features: 'Package references, restore, lock files' }
    ],
    comparison: 'Buildalyzer for simple project analysis. Microsoft.Build for full MSBuild capabilities.'
  },

  SunamoCssGenerator: {
    description: 'CSS generation',
    alternatives: [
      { name: 'LibSassHost', nuget: 'LibSassHost', purpose: 'Sass/SCSS compiler', features: 'CSS generation from Sass, variables, mixins' },
      { name: 'dotless', nuget: 'dotless', purpose: 'LESS compiler for .NET', features: 'Dynamic CSS generation' },
      { name: 'ExCSS', nuget: 'ExCSS', purpose: 'CSS parser and generator', features: 'Parse CSS, manipulate, generate output' }
    ],
    comparison: 'LibSassHost for Sass. ExCSS for programmatic CSS manipulation.'
  },

  SunamoCsv: {
    description: 'CSV file operations',
    alternatives: [
      { name: 'CsvHelper', nuget: 'CsvHelper', purpose: 'Industry-standard CSV library', features: 'Reading, writing, type mapping, configuration' },
      { name: 'TinyCsvParser', nuget: 'TinyCsvParser', purpose: 'Fast CSV parser', features: 'High performance, low memory, parallel processing' },
      { name: 'Sylvan.Data.Csv', nuget: 'Sylvan.Data.Csv', purpose: 'High-performance CSV', features: 'Fastest CSV parser, low allocations' },
      { name: 'FileHelpers', nuget: 'FileHelpers', purpose: 'Delimited and fixed-width files', features: 'CSV, TSV, custom formats' }
    ],
    comparison: 'CsvHelper for features and ease of use. Sylvan.Data.Csv for maximum performance.'
  },

  SunamoData: {
    description: 'Data access utilities',
    alternatives: [
      { name: 'Dapper', nuget: 'Dapper', purpose: 'Micro-ORM', features: 'Fast data mapping, minimal overhead, query support' },
      { name: 'Entity Framework Core', nuget: 'Microsoft.EntityFrameworkCore', purpose: 'Full-featured ORM', features: 'Change tracking, migrations, LINQ queries' },
      { name: 'NHibernate', nuget: 'NHibernate', purpose: 'Mature ORM', features: 'Advanced mapping, caching, lazy loading' },
      { name: 'RepoDb', nuget: 'RepoDb', purpose: 'Hybrid ORM', features: 'Raw SQL + ORM, bulk operations, caching' }
    ],
    comparison: 'Dapper for performance. EF Core for productivity. Choose based on complexity needs.'
  },

  SunamoDateTime: {
    description: 'Date and time utilities',
    alternatives: [
      { name: 'NodaTime', nuget: 'NodaTime', purpose: 'Better date/time API', features: 'Time zones, calendars, immutable types, clear semantics' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Human-readable dates', features: 'Relative time, date formatting, parsing' },
      { name: 'System.DateOnly/TimeOnly', nuget: 'System.Runtime', purpose: '.NET 6+ date/time types', features: 'Separate date and time representations' },
      { name: 'Chronic.Core', nuget: 'Chronic.Core', purpose: 'Natural language date parsing', features: 'Parse "next Tuesday", relative dates' }
    ],
    comparison: 'NodaTime for robust timezone handling. Humanizer for user-facing text. Built-in types often sufficient.'
  },

  SunamoDebugCollection: {
    description: 'Collection debugging utilities',
    alternatives: [
      { name: 'System.Diagnostics.Debug', nuget: 'System.Diagnostics.Debug', purpose: 'Built-in debugging', features: 'Assert, WriteLine, conditional compilation' },
      { name: 'ObjectDumper', nuget: 'ObjectDumper.NET', purpose: 'Object visualization', features: 'Dump objects to string, property inspection' },
      { name: 'Serilog', nuget: 'Serilog', purpose: 'Structured logging', features: 'Log complex objects, structured data' },
      { name: 'BenchmarkDotNet', nuget: 'BenchmarkDotNet', purpose: 'Performance analysis', features: 'Collection performance benchmarking' }
    ],
    comparison: 'ObjectDumper for quick inspection. Serilog for production debugging.'
  },

  SunamoDebugIO: {
    description: 'I/O debugging utilities',
    alternatives: [
      { name: 'Serilog', nuget: 'Serilog', purpose: 'Structured logging', features: 'File sinks, structured events, performance' },
      { name: 'System.Diagnostics.Trace', nuget: 'System.Diagnostics.TraceSource', purpose: 'Built-in tracing', features: 'Trace listeners, event sources' },
      { name: 'NLog', nuget: 'NLog', purpose: 'Flexible logging', features: 'Multiple targets, filtering, async logging' }
    ],
    comparison: 'Serilog for modern structured logging. NLog for configuration flexibility.'
  },

  SunamoDebugging: {
    description: 'General debugging utilities',
    alternatives: [
      { name: 'System.Diagnostics', nuget: 'System.Diagnostics.Debug', purpose: 'Built-in debugging tools', features: 'Debug, Trace, Debugger class, assertions' },
      { name: 'Serilog', nuget: 'Serilog', purpose: 'Diagnostic logging', features: 'Structured logging, context enrichment' },
      { name: 'Ben.Demystifier', nuget: 'Ben.Demystifier', purpose: 'Better stack traces', features: 'Readable async stack traces, source line info' },
      { name: 'MiniProfiler', nuget: 'MiniProfiler', purpose: 'Performance profiling', features: 'Web request profiling, database queries' }
    ],
    comparison: 'Built-in System.Diagnostics for basic debugging. Ben.Demystifier for better error analysis.'
  },

  SunamoDelegates: {
    description: 'Delegate utilities',
    alternatives: [
      { name: 'System.Delegate', nuget: 'System.Runtime', purpose: 'Built-in delegate support', features: 'Action, Func, Predicate, events' },
      { name: 'DynamicExpresso', nuget: 'DynamicExpresso.Core', purpose: 'Dynamic expression evaluation', features: 'Parse and execute C# expressions at runtime' },
      { name: 'System.Linq.Expressions', nuget: 'System.Linq.Expressions', purpose: 'Expression trees', features: 'Build and compile delegates dynamically' }
    ],
    comparison: 'Built-in delegate types (Action, Func) cover most scenarios. Expression trees for dynamic generation.'
  },

  SunamoDependencyInjection: {
    description: 'Dependency injection utilities',
    alternatives: [
      { name: 'Microsoft.Extensions.DependencyInjection', nuget: 'Microsoft.Extensions.DependencyInjection', purpose: 'Official .NET DI container', features: 'Service lifetimes, scoping, IServiceProvider' },
      { name: 'Autofac', nuget: 'Autofac', purpose: 'Popular IoC container', features: 'Modules, decorators, interceptors, lifetime scopes' },
      { name: 'Ninject', nuget: 'Ninject', purpose: 'Lightweight DI framework', features: 'Convention-based binding, kernel configuration' },
      { name: 'SimpleInjector', nuget: 'SimpleInjector', purpose: 'Fast DI container', features: 'High performance, verification, diagnostics' },
      { name: 'DryIoc', nuget: 'DryIoc', purpose: 'Fast IoC container', features: 'Code generation, performance optimized' }
    ],
    comparison: 'Microsoft.Extensions.DI is the standard. Autofac for advanced features. SimpleInjector/DryIoc for performance.'
  },

  SunamoDevCode: {
    description: 'Code generation and development utilities',
    alternatives: [
      { name: 'Microsoft.CodeAnalysis', nuget: 'Microsoft.CodeAnalysis.CSharp', purpose: 'Roslyn compiler API', features: 'Syntax trees, semantic analysis, code generation' },
      { name: 'CodeGeneration.Roslyn', nuget: 'CodeGeneration.Roslyn', purpose: 'Source generators', features: 'Compile-time code generation' },
      { name: 'T4', nuget: 'Microsoft.VisualStudio.TextTemplating', purpose: 'Text template transformation', features: 'Code generation from templates' },
      { name: 'Scriban', nuget: 'Scriban', purpose: 'Template engine', features: 'Fast, safe text generation' }
    ],
    comparison: 'Roslyn for C# code analysis. Source generators for compile-time generation. Scriban for text templates.'
  },

  SunamoDictionary: {
    description: 'Dictionary utilities',
    alternatives: [
      { name: 'System.Collections.Generic.Dictionary', nuget: 'System.Collections', purpose: 'Built-in dictionary', features: 'O(1) lookup, key-value pairs' },
      { name: 'System.Collections.Concurrent.ConcurrentDictionary', nuget: 'System.Collections.Concurrent', purpose: 'Thread-safe dictionary', features: 'Concurrent access, atomic operations' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Dictionary extensions', features: 'ToDictionary variants, grouping operations' },
      { name: 'System.Collections.Immutable', nuget: 'System.Collections.Immutable', purpose: 'Immutable dictionaries', features: 'Thread-safe, persistent data structures' }
    ],
    comparison: 'Dictionary<K,V> for standard use. ConcurrentDictionary for thread safety. ImmutableDictionary for functional programming.'
  },

  SunamoDotnetCmdBuilder: {
    description: 'Dotnet CLI command builder',
    alternatives: [
      { name: 'CliWrap', nuget: 'CliWrap', purpose: 'Process execution wrapper', features: 'Fluent API, piping, async, validation' },
      { name: 'Cake', nuget: 'Cake.Core', purpose: 'Build automation system', features: 'DSL for builds, dotnet tool integration' },
      { name: 'Bullseye', nuget: 'Bullseye', purpose: 'Target-based task runner', features: 'Dependency graphs, parallel execution' },
      { name: 'System.Diagnostics.Process', nuget: 'System.Diagnostics.Process', purpose: 'Built-in process execution', features: 'Start processes, capture output' }
    ],
    comparison: 'CliWrap for clean process execution. Cake/Bullseye for build automation.'
  },

  SunamoDotNetZip: {
    description: 'ZIP archive operations',
    alternatives: [
      { name: 'System.IO.Compression.ZipFile', nuget: 'System.IO.Compression.ZipFile', purpose: 'Built-in ZIP support', features: 'Create, extract, update ZIP archives' },
      { name: 'SharpZipLib', nuget: 'SharpZipLib', purpose: 'Comprehensive compression library', features: 'ZIP, GZip, Tar, BZip2' },
      { name: 'DotNetZip', nuget: 'DotNetZip', purpose: 'Feature-rich ZIP library', features: 'Password protection, ZIP64, AES encryption' },
      { name: 'SharpCompress', nuget: 'SharpCompress', purpose: 'Multiple archive formats', features: 'ZIP, RAR, 7z, tar, gzip support' }
    ],
    comparison: 'System.IO.Compression for basic ZIP. SharpCompress for multiple formats.'
  },

  SunamoEditorConfig: {
    description: 'EditorConfig file handling',
    alternatives: [
      { name: 'EditorConfig.Core', nuget: 'EditorConfig.Core', purpose: 'EditorConfig parser', features: 'Parse .editorconfig files, property resolution' },
      { name: 'Microsoft.CodeAnalysis.EditorConfig', nuget: 'Microsoft.CodeAnalysis', purpose: 'Roslyn EditorConfig support', features: 'Code style enforcement, analyzer configuration' }
    ],
    comparison: 'EditorConfig.Core for parsing. Roslyn integration for code analysis.'
  },

  SunamoEmbeddedResources: {
    description: 'Embedded resource management',
    alternatives: [
      { name: 'System.Reflection.Assembly', nuget: 'System.Reflection', purpose: 'Built-in resource access', features: 'GetManifestResourceStream, embedded file access' },
      { name: 'EmbeddedResource', nuget: 'EmbeddedResource.Utility', purpose: 'Resource utility library', features: 'Simplified embedded resource access' },
      { name: 'ResourceReader', nuget: 'System.Resources.ResourceReader', purpose: 'Resource file reading', features: '.resx file access' }
    ],
    comparison: 'System.Reflection.Assembly methods are standard for embedded resources.'
  },

  SunamoEmoticons: {
    description: 'Emoticon and emoji utilities',
    alternatives: [
      { name: 'Emoji.Net', nuget: 'Emoji.Net', purpose: 'Emoji detection and manipulation', features: 'Unicode emoji support, text replacement' },
      { name: 'NeoSmart.Unicode', nuget: 'NeoSmart.Unicode.Emoji', purpose: 'Emoji library', features: 'Emoji sequences, skin tones, categories' },
      { name: 'System.Text.Unicode', nuget: 'System.Text.Encodings.Web', purpose: 'Unicode utilities', features: 'Emoji rendering, encoding' }
    ],
    comparison: 'Emoji.Net for basic emoji operations. NeoSmart.Unicode for comprehensive emoji support.'
  },

  SunamoEnums: {
    description: 'Enum utilities',
    alternatives: [
      { name: 'System.Enum', nuget: 'System.Runtime', purpose: 'Built-in enum operations', features: 'Parse, GetValues, GetNames, HasFlag' },
      { name: 'Enums.NET', nuget: 'Enums.NET', purpose: 'High-performance enum library', features: 'Fast operations, attributes, descriptions' },
      { name: 'SmartEnum', nuget: 'Ardalis.SmartEnum', purpose: 'Type-safe enum replacement', features: 'Rich domain models, behaviors, validation' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Enum humanization', features: 'Display names, descriptions, casing' }
    ],
    comparison: 'Built-in Enum methods for basic operations. Enums.NET for performance. SmartEnum for rich enumerations.'
  },

  SunamoEnumsHelper: {
    description: 'Enum helper utilities',
    alternatives: [
      { name: 'Enums.NET', nuget: 'Enums.NET', purpose: 'Comprehensive enum utilities', features: 'Validation, descriptions, flags, parsing' },
      { name: 'UnconstrainedMelody', nuget: 'UnconstrainedMelody', purpose: 'Generic enum constraints', features: 'Type-safe enum operations' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Enum display helpers', features: 'Humanize enum values, descriptions' }
    ],
    comparison: 'Enums.NET provides the most comprehensive enum utilities.'
  },

  SunamoExceptions: {
    description: 'Exception handling utilities',
    alternatives: [
      { name: 'Polly', nuget: 'Polly', purpose: 'Resilience and exception handling', features: 'Retry, circuit breaker, fallback policies' },
      { name: 'Ben.Demystifier', nuget: 'Ben.Demystifier', purpose: 'Better exception messages', features: 'Clean async stack traces, readable errors' },
      { name: 'System.Diagnostics.DiagnosticSource', nuget: 'System.Diagnostics.DiagnosticSource', purpose: 'Exception tracking', features: 'Activity tracking, distributed tracing' },
      { name: 'Serilog', nuget: 'Serilog', purpose: 'Exception logging', features: 'Structured exception logging, enrichment' }
    ],
    comparison: 'Polly for resilient exception handling. Ben.Demystifier for better diagnostics.'
  },

  SunamoExtensions: {
    description: 'General extension methods',
    alternatives: [
      { name: 'System.Linq', nuget: 'System.Linq', purpose: 'LINQ extension methods', features: 'Query operators, transformations' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Additional LINQ extensions', features: '50+ extension methods for collections' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'String and type extensions', features: 'Pluralization, date/time, enum humanization' },
      { name: 'Z.ExtensionMethods', nuget: 'Z.ExtensionMethods', purpose: 'Comprehensive extensions', features: '1000+ extension methods for all types' }
    ],
    comparison: 'MoreLINQ for collection extensions. Humanizer for string/date operations.'
  },

  SunamoFileExtensions: {
    description: 'File extension utilities',
    alternatives: [
      { name: 'System.IO.Path', nuget: 'System.Runtime', purpose: 'Built-in path operations', features: 'GetExtension, ChangeExtension, file name parsing' },
      { name: 'MimeMapping', nuget: 'MimeMapping', purpose: 'Extension to MIME type mapping', features: 'File type detection from extensions' },
      { name: 'HeyRed.Mime', nuget: 'HeyRed.Mime', purpose: 'MIME type detection', features: 'Extension lookup, content-based detection' }
    ],
    comparison: 'System.IO.Path for basic extension operations. MimeMapping for MIME types.'
  },

  SunamoFileIO: {
    description: 'File I/O operations',
    alternatives: [
      { name: 'System.IO.File', nuget: 'System.IO.FileSystem', purpose: 'Built-in file operations', features: 'Read, write, copy, delete, exists checks' },
      { name: 'System.IO.Abstractions', nuget: 'System.IO.Abstractions', purpose: 'Testable file I/O', features: 'Mockable file system, dependency injection' },
      { name: 'Zio', nuget: 'Zio', purpose: 'Virtual file systems', features: 'Memory FS, sub FS, aggregated FS' },
      { name: 'Polly', nuget: 'Polly', purpose: 'Resilient file operations', features: 'Retry on failures, transient error handling' }
    ],
    comparison: 'System.IO for standard operations. System.IO.Abstractions for testable code.'
  },

  SunamoFilesIndex: {
    description: 'File indexing utilities',
    alternatives: [
      { name: 'Lucene.Net', nuget: 'Lucene.Net', purpose: 'Full-text search engine', features: 'File indexing, search, analyzers' },
      { name: 'LiteDB', nuget: 'LiteDB', purpose: 'Embedded NoSQL database', features: 'Document indexing, full-text search' },
      { name: 'System.IO.FileSystemWatcher', nuget: 'System.IO.FileSystem.Watcher', purpose: 'File system monitoring', features: 'Track file changes, events' }
    ],
    comparison: 'Lucene.Net for full-text search. FileSystemWatcher for change tracking.'
  },

  SunamoFileSystem: {
    description: 'File system utilities',
    alternatives: [
      { name: 'System.IO', nuget: 'System.IO.FileSystem', purpose: 'Built-in file system APIs', features: 'File, Directory, Path, DriveInfo operations' },
      { name: 'System.IO.Abstractions', nuget: 'System.IO.Abstractions', purpose: 'Mockable file system', features: 'IFileSystem interface, testing support' },
      { name: 'Zio', nuget: 'Zio', purpose: 'Virtual file systems', features: 'In-memory FS, composable file systems' },
      { name: 'Alphaleonis.Win32.Filesystem', nuget: 'AlphaFS', purpose: 'Extended Windows file operations', features: 'Long paths, transactional NTFS, advanced features' }
    ],
    comparison: 'System.IO for standard operations. AlphaFS for Windows-specific advanced features.'
  },

  SunamoFluentFtp: {
    description: 'FTP operations using FluentFTP',
    alternatives: [
      { name: 'FluentFTP', nuget: 'FluentFTP', purpose: 'Modern FTP/FTPS client', features: 'Async operations, SSL/TLS, directory operations' },
      { name: 'SSH.NET', nuget: 'SSH.NET', purpose: 'SSH/SFTP client', features: 'SFTP, SSH commands, key authentication' },
      { name: 'WinSCP', nuget: 'WinSCP', purpose: 'FTP/SFTP wrapper', features: 'WinSCP automation, scripting' },
      { name: 'System.Net.FtpWebRequest', nuget: 'System.Net.Requests', purpose: 'Built-in FTP (deprecated)', features: 'Basic FTP operations (legacy)' }
    ],
    comparison: 'FluentFTP is the best modern FTP library. SSH.NET for SFTP.'
  },

  SunamoFtp: {
    description: 'FTP utilities',
    alternatives: [
      { name: 'FluentFTP', nuget: 'FluentFTP', purpose: 'Full-featured FTP client', features: 'FTP, FTPS, async, streaming' },
      { name: 'SSH.NET', nuget: 'SSH.NET', purpose: 'SFTP client', features: 'Secure file transfers, SSH' }
    ],
    comparison: 'FluentFTP for FTP/FTPS. SSH.NET for SFTP.'
  },

  SunamoGetFiles: {
    description: 'File enumeration utilities',
    alternatives: [
      { name: 'System.IO.Directory', nuget: 'System.IO.FileSystem', purpose: 'Built-in file enumeration', features: 'GetFiles, EnumerateFiles, search patterns' },
      { name: 'Microsoft.Extensions.FileSystemGlobbing', nuget: 'Microsoft.Extensions.FileSystemGlobbing', purpose: 'Glob pattern matching', features: 'Pattern-based file search, includes/excludes' },
      { name: 'DotNet.Glob', nuget: 'DotNet.Glob', purpose: 'Glob matching', features: 'Fast glob pattern evaluation' },
      { name: 'System.IO.Abstractions', nuget: 'System.IO.Abstractions', purpose: 'Testable file enumeration', features: 'Mockable directory operations' }
    ],
    comparison: 'Directory.EnumerateFiles for standard use. FileSystemGlobbing for complex patterns.'
  },

  SunamoGetFolders: {
    description: 'Folder enumeration utilities',
    alternatives: [
      { name: 'System.IO.Directory', nuget: 'System.IO.FileSystem', purpose: 'Built-in directory operations', features: 'GetDirectories, EnumerateDirectories, recursive search' },
      { name: 'Microsoft.Extensions.FileSystemGlobbing', nuget: 'Microsoft.Extensions.FileSystemGlobbing', purpose: 'Directory pattern matching', features: 'Glob patterns for folders' },
      { name: 'System.IO.Abstractions', nuget: 'System.IO.Abstractions', purpose: 'Testable folder operations', features: 'IDirectory interface' }
    ],
    comparison: 'Built-in Directory class covers most folder enumeration needs.'
  },

  SunamoGitConfig: {
    description: 'Git configuration utilities',
    alternatives: [
      { name: 'LibGit2Sharp', nuget: 'LibGit2Sharp', purpose: 'Git operations in .NET', features: 'Repository operations, config access, commits, branches' },
      { name: 'GitInfo', nuget: 'GitInfo', purpose: 'Git information at build time', features: 'Embed git info in assemblies, version tagging' },
      { name: 'CliWrap', nuget: 'CliWrap', purpose: 'Execute git CLI commands', features: 'Process execution wrapper for git' }
    ],
    comparison: 'LibGit2Sharp for full Git API access. GitInfo for build-time git information.'
  },

  SunamoGoogleMyMaps: {
    description: 'Google My Maps integration',
    alternatives: [
      { name: 'Google.Apis.Maps', nuget: 'Google.Apis.Maps', purpose: 'Google Maps API client', features: 'Maps, geocoding, directions' },
      { name: 'GoogleApi', nuget: 'GoogleApi', purpose: 'Google APIs wrapper', features: 'Maps, Places, Geocoding, Distance Matrix' },
      { name: 'NetTopologySuite', nuget: 'NetTopologySuite', purpose: 'Spatial data processing', features: 'GIS operations, geometries, spatial analysis' }
    ],
    comparison: 'Use official Google.Apis for Google services. NetTopologySuite for offline spatial processing.'
  },

  SunamoGoogleSheets: {
    description: 'Google Sheets integration',
    alternatives: [
      { name: 'Google.Apis.Sheets.v4', nuget: 'Google.Apis.Sheets.v4', purpose: 'Official Google Sheets API', features: 'Read, write, format spreadsheets' },
      { name: 'GoogleSheetsWrapper', nuget: 'GoogleSheetsWrapper', purpose: 'Simplified Sheets access', features: 'Easy CRUD operations' },
      { name: 'EPPlus', nuget: 'EPPlus', purpose: 'Excel alternative (offline)', features: 'Create Excel files locally' }
    ],
    comparison: 'Use official Google.Apis.Sheets.v4 for Google Sheets integration.'
  },

  SunamoGpx: {
    description: 'GPX file handling',
    alternatives: [
      { name: 'NetTopologySuite.IO.GPX', nuget: 'NetTopologySuite.IO.GPX', purpose: 'GPX reading/writing', features: 'Parse GPX, spatial operations' },
      { name: 'GpxUtils', nuget: 'GpxUtils', purpose: 'GPX utilities', features: 'Parse, create, manipulate GPX files' },
      { name: 'SharpGPX', nuget: 'SharpGpx', purpose: 'GPX library', features: 'Track, route, waypoint handling' }
    ],
    comparison: 'NetTopologySuite.IO.GPX for comprehensive GPX + spatial operations.'
  },

  SunamoHtml: {
    description: 'HTML parsing and manipulation',
    alternatives: [
      { name: 'HtmlAgilityPack', nuget: 'HtmlAgilityPack', purpose: 'Industry-standard HTML parser', features: 'XPath, LINQ to HTML, DOM manipulation' },
      { name: 'AngleSharp', nuget: 'AngleSharp', purpose: 'Modern HTML/CSS parser', features: 'Standards-compliant, CSS selectors, DOM API' },
      { name: 'CsQuery', nuget: 'CsQuery', purpose: 'jQuery-like HTML parser', features: 'CSS selectors, jQuery syntax' },
      { name: 'Fizzler', nuget: 'Fizzler', purpose: 'CSS selector engine', features: 'Works with HtmlAgilityPack' }
    ],
    comparison: 'HtmlAgilityPack is most popular. AngleSharp for standards compliance and CSS selector support.'
  },

  SunamoHttp: {
    description: 'HTTP client utilities',
    alternatives: [
      { name: 'System.Net.Http.HttpClient', nuget: 'System.Net.Http', purpose: 'Built-in HTTP client', features: 'Async requests, headers, content types' },
      { name: 'Flurl.Http', nuget: 'Flurl.Http', purpose: 'Fluent HTTP client', features: 'Fluent API, URL building, JSON handling' },
      { name: 'RestSharp', nuget: 'RestSharp', purpose: 'REST API client', features: 'Serialization, authentication, easy REST calls' },
      { name: 'Refit', nuget: 'Refit', purpose: 'Type-safe REST client', features: 'Interface-based API definition, automatic implementation' }
    ],
    comparison: 'HttpClient for standard use. Flurl.Http for fluent API. Refit for type-safe APIs.'
  },

  SunamoIni: {
    description: 'INI file handling',
    alternatives: [
      { name: 'IniParser', nuget: 'ini-parser', purpose: 'INI file parser', features: 'Read, write, modify INI files' },
      { name: 'Nini', nuget: 'Nini', purpose: 'Configuration library', features: 'INI, XML, registry, command-line config' },
      { name: 'Microsoft.Extensions.Configuration.Ini', nuget: 'Microsoft.Extensions.Configuration.Ini', purpose: 'INI configuration provider', features: 'Integrate INI with .NET configuration' }
    ],
    comparison: 'IniParser for standalone INI operations. Microsoft.Extensions.Configuration.Ini for .NET Core apps.'
  },

  SunamoInterfaces: {
    description: 'Common interfaces and abstractions',
    alternatives: [
      { name: 'System.Runtime', nuget: 'System.Runtime', purpose: 'Built-in BCL interfaces', features: 'IDisposable, IComparable, IEquatable, IEnumerable' },
      { name: 'System.ComponentModel', nuget: 'System.ComponentModel', purpose: 'Component interfaces', features: 'INotifyPropertyChanged, IDataErrorInfo' },
      { name: 'MediatR.Contracts', nuget: 'MediatR.Contracts', purpose: 'Mediator pattern interfaces', features: 'IRequest, INotification abstractions' }
    ],
    comparison: 'Most interface needs are covered by System.Runtime and System.ComponentModel.'
  },

  SunamoJson: {
    description: 'JSON serialization/deserialization',
    alternatives: [
      { name: 'System.Text.Json', nuget: 'System.Text.Json', purpose: 'Built-in high-performance JSON', features: 'Fast, low-allocation, modern API' },
      { name: 'Newtonsoft.Json', nuget: 'Newtonsoft.Json', purpose: 'Json.NET - most popular JSON library', features: 'Flexible, extensive features, LINQ to JSON' },
      { name: 'Utf8Json', nuget: 'Utf8Json', purpose: 'Fastest JSON serializer', features: 'Zero-allocation, code generation' },
      { name: 'Jil', nuget: 'Jil', purpose: 'Fast JSON serializer', features: 'Performance-focused, simple API' }
    ],
    comparison: 'System.Text.Json for new projects. Newtonsoft.Json for compatibility and features.'
  },

  SunamoLang: {
    description: 'Language and localization utilities',
    alternatives: [
      { name: 'Microsoft.Extensions.Localization', nuget: 'Microsoft.Extensions.Localization', purpose: 'Official .NET localization', features: 'Resource strings, culture support, dependency injection' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Multi-language string manipulation', features: 'Pluralization, inflection for 35+ languages' },
      { name: 'Globalization', nuget: 'System.Globalization', purpose: 'Built-in globalization', features: 'CultureInfo, number/date formatting' },
      { name: 'ResXResourceManager', nuget: 'ResXResourceManager', purpose: 'Resource file management', features: 'Visual .resx editor, translation workflow' }
    ],
    comparison: 'Microsoft.Extensions.Localization for .NET Core. Built-in Globalization for basic culture support.'
  },

  SunamoLaTeX: {
    description: 'LaTeX document processing',
    alternatives: [
      { name: 'LatexNET', nuget: 'LatexNET', purpose: 'LaTeX document generation', features: 'Create LaTeX documents programmatically' },
      { name: 'MiKTeX.NET', nuget: 'MiKTeX.NET', purpose: 'LaTeX compilation', features: 'Compile LaTeX to PDF' },
      { name: 'CliWrap', nuget: 'CliWrap', purpose: 'Execute LaTeX tools', features: 'Call pdflatex, xelatex commands' }
    ],
    comparison: 'Most LaTeX integration involves calling command-line tools via CliWrap.'
  },

  SunamoLogging: {
    description: 'Logging utilities',
    alternatives: [
      { name: 'Serilog', nuget: 'Serilog', purpose: 'Structured logging library', features: 'Sinks, enrichers, structured events' },
      { name: 'NLog', nuget: 'NLog', purpose: 'Flexible logging framework', features: 'Multiple targets, configuration, filtering' },
      { name: 'Microsoft.Extensions.Logging', nuget: 'Microsoft.Extensions.Logging', purpose: 'Official .NET logging abstraction', features: 'ILogger, logging providers, DI integration' },
      { name: 'log4net', nuget: 'log4net', purpose: 'Apache logging framework', features: 'Appenders, levels, hierarchical configuration' }
    ],
    comparison: 'Serilog for structured logging. Microsoft.Extensions.Logging for abstraction. NLog for flexibility.'
  },

  SunamoMail: {
    description: 'Email operations',
    alternatives: [
      { name: 'MailKit', nuget: 'MailKit', purpose: 'Modern email library', features: 'SMTP, IMAP, POP3, MIME, OAuth2' },
      { name: 'FluentEmail', nuget: 'FluentEmail.Core', purpose: 'Fluent email API', features: 'Templates, attachments, multiple senders' },
      { name: 'MimeKit', nuget: 'MimeKit', purpose: 'MIME message parsing', features: 'Email parsing, construction, S/MIME, PGP' },
      { name: 'System.Net.Mail', nuget: 'System.Net.Mail', purpose: 'Built-in SMTP (legacy)', features: 'Basic SMTP (not recommended)' }
    ],
    comparison: 'MailKit is the gold standard for email in .NET. FluentEmail for simplified API.'
  },

  SunamoMarkdown: {
    description: 'Markdown processing',
    alternatives: [
      { name: 'Markdig', nuget: 'Markdig', purpose: 'Fast, extensible Markdown processor', features: 'CommonMark, GitHub flavored, pipelines, extensions' },
      { name: 'CommonMark.NET', nuget: 'CommonMark.NET', purpose: 'CommonMark parser', features: 'Standard Markdown, fast parsing' },
      { name: 'Markdown', nuget: 'Markdown', purpose: 'Simple Markdown library', features: 'Basic Markdown to HTML' },
      { name: 'MarkdownSharp', nuget: 'MarkdownSharp', purpose: 'Stack Overflow Markdown', features: 'Markdown used by Stack Overflow' }
    ],
    comparison: 'Markdig is the fastest and most feature-complete. Recommended for all new projects.'
  },

  SunamoMathpix: {
    description: 'Mathpix OCR integration',
    alternatives: [
      { name: 'Mathpix.NET', nuget: 'Mathpix.NET', purpose: 'Mathpix API client', features: 'Math OCR, LaTeX conversion' },
      { name: 'Azure.AI.FormRecognizer', nuget: 'Azure.AI.FormRecognizer', purpose: 'Microsoft OCR', features: 'Document OCR, form extraction' },
      { name: 'IronOcr', nuget: 'IronOcr', purpose: 'OCR library', features: 'Text extraction, multiple languages' },
      { name: 'Tesseract', nuget: 'Tesseract', purpose: 'Open-source OCR', features: 'Multi-language text recognition' }
    ],
    comparison: 'Specific OCR needs vary. Mathpix for math. Azure for documents. Tesseract for general OCR.'
  },

  SunamoMime: {
    description: 'MIME type utilities',
    alternatives: [
      { name: 'MimeKit', nuget: 'MimeKit', purpose: 'MIME message library', features: 'MIME parsing, headers, multipart' },
      { name: 'MimeMapping', nuget: 'MimeMapping', purpose: 'File extension to MIME mapping', features: 'Extension lookup, content type detection' },
      { name: 'HeyRed.Mime', nuget: 'HeyRed.Mime', purpose: 'MIME detection', features: 'Content-based type detection' },
      { name: 'MimeTypesMap', nuget: 'MimeTypesMap', purpose: 'MIME type mappings', features: 'Comprehensive extension database' }
    ],
    comparison: 'MimeKit for MIME messages. MimeMapping for file type detection.'
  },

  SunamoMsgReader: {
    description: 'Outlook MSG file reading',
    alternatives: [
      { name: 'MSGReader', nuget: 'MSGReader', purpose: 'Outlook MSG file parser', features: 'Read .msg files, extract attachments, properties' },
      { name: 'MsgKit', nuget: 'MsgKit', purpose: 'MSG file creation/reading', features: 'Create and parse Outlook messages' },
      { name: 'Aspose.Email', nuget: 'Aspose.Email', purpose: 'Email processing library', features: 'MSG, EML, PST, MBOX support (commercial)' }
    ],
    comparison: 'MSGReader for free MSG parsing. MsgKit for creation. Aspose for commercial needs.'
  },

  SunamoMsSqlServer: {
    description: 'SQL Server utilities',
    alternatives: [
      { name: 'System.Data.SqlClient', nuget: 'System.Data.SqlClient', purpose: 'ADO.NET SQL Server provider', features: 'Direct SQL Server access' },
      { name: 'Microsoft.Data.SqlClient', nuget: 'Microsoft.Data.SqlClient', purpose: 'Modern SQL Server provider', features: 'Latest features, actively maintained' },
      { name: 'Dapper', nuget: 'Dapper', purpose: 'Micro-ORM', features: 'Fast data mapping, simple queries' },
      { name: 'Entity Framework Core', nuget: 'Microsoft.EntityFrameworkCore.SqlServer', purpose: 'Full ORM', features: 'Code-first, migrations, LINQ' }
    ],
    comparison: 'Microsoft.Data.SqlClient for ADO.NET. Dapper for micro-ORM. EF Core for full ORM.'
  },

  SunamoNuGetProtocol: {
    description: 'NuGet protocol utilities',
    alternatives: [
      { name: 'NuGet.Protocol', nuget: 'NuGet.Protocol', purpose: 'Official NuGet protocol library', features: 'Package sources, search, download' },
      { name: 'NuGet.Packaging', nuget: 'NuGet.Packaging', purpose: 'Package manipulation', features: 'Create, extract, read .nupkg files' },
      { name: 'NuGet.Versioning', nuget: 'NuGet.Versioning', purpose: 'Version parsing and comparison', features: 'Semantic versioning, ranges' }
    ],
    comparison: 'Official NuGet libraries provide complete NuGet API access.'
  },

  SunamoNumbers: {
    description: 'Number utilities',
    alternatives: [
      { name: 'System.Numerics', nuget: 'System.Numerics', purpose: 'Built-in numeric types', features: 'BigInteger, Complex, Vector' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Number humanization', features: 'Number to words, ordinals, Roman numerals' },
      { name: 'MathNet.Numerics', nuget: 'MathNet.Numerics', purpose: 'Mathematical library', features: 'Linear algebra, statistics, special functions' },
      { name: 'UnitsNet', nuget: 'UnitsNet', purpose: 'Units of measurement', features: 'Type-safe unit conversions' }
    ],
    comparison: 'System.Numerics for basic needs. MathNet.Numerics for advanced math. UnitsNet for unit conversions.'
  },

  SunamoOctokit: {
    description: 'GitHub API integration',
    alternatives: [
      { name: 'Octokit', nuget: 'Octokit', purpose: 'Official GitHub API client', features: 'Repositories, issues, pull requests, gists' },
      { name: 'Octokit.GraphQL', nuget: 'Octokit.GraphQL', purpose: 'GitHub GraphQL API', features: 'Modern GraphQL-based access' },
      { name: 'LibGit2Sharp', nuget: 'LibGit2Sharp', purpose: 'Git operations', features: 'Local Git repository operations' }
    ],
    comparison: 'Octokit is the standard for GitHub API integration.'
  },

  SunamoPInvoke: {
    description: 'P/Invoke utilities',
    alternatives: [
      { name: 'PInvoke.Kernel32', nuget: 'PInvoke.Kernel32', purpose: 'Windows API P/Invoke signatures', features: 'Type-safe Win32 imports' },
      { name: 'PInvoke.User32', nuget: 'PInvoke.User32', purpose: 'User32.dll imports', features: 'Window management, input' },
      { name: 'Vanara', nuget: 'Vanara.PInvoke', purpose: 'Comprehensive Windows API', features: 'All Windows APIs, COM support' },
      { name: 'pinvoke.net', nuget: null, purpose: 'P/Invoke reference site', features: 'Community signatures database' }
    ],
    comparison: 'Vanara provides the most comprehensive Windows API coverage. PInvoke.* for specific APIs.'
  },

  SunamoPS: {
    description: 'PowerShell automation',
    alternatives: [
      { name: 'System.Management.Automation', nuget: 'Microsoft.PowerShell.SDK', purpose: 'PowerShell SDK', features: 'Host PowerShell, execute scripts, cmdlets' },
      { name: 'PowerShell.SDK', nuget: 'PowerShell.SDK', purpose: 'PowerShell Core SDK', features: 'Cross-platform PowerShell hosting' },
      { name: 'CliWrap', nuget: 'CliWrap', purpose: 'Execute PowerShell commands', features: 'Process execution wrapper' }
    ],
    comparison: 'Microsoft.PowerShell.SDK for embedding PowerShell. CliWrap for simple command execution.'
  },

  SunamoPackageJson: {
    description: 'package.json file handling',
    alternatives: [
      { name: 'System.Text.Json', nuget: 'System.Text.Json', purpose: 'JSON parsing', features: 'Parse package.json as JSON' },
      { name: 'Newtonsoft.Json', nuget: 'Newtonsoft.Json', purpose: 'JSON manipulation', features: 'Read, modify, write package.json' },
      { name: 'NuGet.Versioning', nuget: 'NuGet.Versioning', purpose: 'Semantic versioning', features: 'Parse npm version ranges' }
    ],
    comparison: 'Standard JSON libraries handle package.json. NuGet.Versioning for version parsing.'
  },

  SunamoParsing: {
    description: 'Parsing utilities',
    alternatives: [
      { name: 'Sprache', nuget: 'Sprache', purpose: 'Parser combinator library', features: 'Build parsers with LINQ, monadic parsing' },
      { name: 'Superpower', nuget: 'Superpower', purpose: 'Text parsing library', features: 'Token-based parsing, error messages' },
      { name: 'Pidgin', nuget: 'Pidgin', purpose: 'Fast parser combinator', features: 'High performance, good errors' },
      { name: 'ANTLR', nuget: 'Antlr4.Runtime.Standard', purpose: 'Parser generator', features: 'Generate parsers from grammars' }
    ],
    comparison: 'Sprache for simple DSLs. ANTLR for complex grammars. Pidgin for performance.'
  },

  SunamoPaths: {
    description: 'File path utilities',
    alternatives: [
      { name: 'System.IO.Path', nuget: 'System.Runtime', purpose: 'Built-in path operations', features: 'Combine, GetFileName, GetExtension, normalization' },
      { name: 'Zio', nuget: 'Zio', purpose: 'Path abstraction', features: 'UPath, cross-platform paths' },
      { name: 'Path.Net', nuget: 'Path.Net', purpose: 'Enhanced path handling', features: 'Fluent API, path building' }
    ],
    comparison: 'System.IO.Path covers most path operations. Zio for virtual file systems.'
  },

  SunamoPercentCalculator: {
    description: 'Percentage calculations',
    alternatives: [
      { name: 'System.Math', nuget: 'System.Runtime', purpose: 'Built-in math operations', features: 'Basic arithmetic, rounding' },
      { name: 'MathNet.Numerics', nuget: 'MathNet.Numerics', purpose: 'Mathematical library', features: 'Statistics, distributions, percentiles' },
      { name: 'UnitsNet', nuget: 'UnitsNet', purpose: 'Unit conversions', features: 'Ratio, percentage units' }
    ],
    comparison: 'Simple percentage calculations use built-in operators. MathNet for statistical percentiles.'
  },

  SunamoPlatformUwpInterop: {
    description: 'UWP platform interop',
    alternatives: [
      { name: 'Windows.UI', nuget: 'Microsoft.Windows.SDK.Contracts', purpose: 'UWP APIs', features: 'Windows Runtime APIs' },
      { name: 'Microsoft.Toolkit.Uwp', nuget: 'Microsoft.Toolkit.Uwp', purpose: 'UWP Community Toolkit', features: 'Helpers, extensions, controls' },
      { name: 'CommunityToolkit.WinUI', nuget: 'CommunityToolkit.WinUI', purpose: 'WinUI toolkit', features: 'Modern Windows UI helpers' }
    ],
    comparison: 'Use platform-specific toolkits for UWP interop.'
  },

  SunamoRandom: {
    description: 'Random number generation',
    alternatives: [
      { name: 'System.Random', nuget: 'System.Runtime', purpose: 'Built-in PRNG', features: 'Basic random numbers' },
      { name: 'System.Security.Cryptography.RandomNumberGenerator', nuget: 'System.Security.Cryptography', purpose: 'Cryptographically secure RNG', features: 'Secure random generation' },
      { name: 'Bogus', nuget: 'Bogus', purpose: 'Fake data generator', features: 'Random test data, names, addresses, etc.' },
      { name: 'MathNet.Numerics', nuget: 'MathNet.Numerics', purpose: 'Statistical distributions', features: 'Normal, uniform, Poisson distributions' }
    ],
    comparison: 'System.Random for basic use. RandomNumberGenerator for security. Bogus for test data.'
  },

  SunamoReflection: {
    description: 'Reflection utilities',
    alternatives: [
      { name: 'System.Reflection', nuget: 'System.Reflection', purpose: 'Built-in reflection', features: 'Type inspection, member access, assembly loading' },
      { name: 'FastMember', nuget: 'FastMember', purpose: 'High-performance reflection', features: 'Fast property access, member iteration' },
      { name: 'Fasterflect', nuget: 'Fasterflect', purpose: 'Optimized reflection', features: 'Cached reflection calls, performance' },
      { name: 'Reflection.Emit', nuget: 'System.Reflection.Emit', purpose: 'Dynamic code generation', features: 'IL generation, dynamic types' }
    ],
    comparison: 'System.Reflection for standard use. FastMember for performance-critical reflection.'
  },

  SunamoRegex: {
    description: 'Regular expression utilities',
    alternatives: [
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Built-in regex engine', features: 'Pattern matching, groups, replacements' },
      { name: 'RegExtract', nuget: 'RegExtract', purpose: 'Regex extraction helper', features: 'Simplified pattern extraction' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'String transformations', features: 'Alternative to regex for common string operations' },
      { name: 'RE2.NET', nuget: 'RE2.NET', purpose: 'Google RE2 for .NET', features: 'Safe, guaranteed linear time regex' }
    ],
    comparison: 'System.Text.RegularExpressions is sufficient for most needs. RE2.NET for untrusted input.'
  },

  SunamoResult: {
    description: 'Result pattern implementation',
    alternatives: [
      { name: 'FluentResults', nuget: 'FluentResults', purpose: 'Result pattern library', features: 'Success/failure, errors, reasons, fluent API' },
      { name: 'LanguageExt', nuget: 'LanguageExt.Core', purpose: 'Functional programming library', features: 'Either, Option, Result types' },
      { name: 'ErrorOr', nuget: 'ErrorOr', purpose: 'Result pattern', features: 'Discriminated unions for errors' },
      { name: 'OneOf', nuget: 'OneOf', purpose: 'Discriminated unions', features: 'Type-safe result handling' }
    ],
    comparison: 'FluentResults for OOP approach. LanguageExt for functional programming. OneOf for simple unions.'
  },

  SunamoRobotsTxt: {
    description: 'robots.txt parsing',
    alternatives: [
      { name: 'RobotsTxt', nuget: 'RobotsTxt', purpose: 'robots.txt parser', features: 'Parse and query robots.txt rules' },
      { name: 'Robots.Txt.Parser', nuget: 'Robots.Txt.Parser', purpose: 'robots.txt handling', features: 'User-agent matching, crawl delay' },
      { name: 'AngleSharp', nuget: 'AngleSharp', purpose: 'Web scraping with robots.txt', features: 'HTML parsing + robots.txt support' }
    ],
    comparison: 'Use dedicated robots.txt libraries for crawlers and scrapers.'
  },

  SunamoRoslyn: {
    description: 'Roslyn compiler utilities',
    alternatives: [
      { name: 'Microsoft.CodeAnalysis.CSharp', nuget: 'Microsoft.CodeAnalysis.CSharp', purpose: 'Roslyn C# compiler API', features: 'Syntax trees, semantic analysis, compilation' },
      { name: 'Microsoft.CodeAnalysis.Workspaces', nuget: 'Microsoft.CodeAnalysis.Workspaces', purpose: 'Solution/project API', features: 'Load solutions, documents, apply changes' },
      { name: 'Buildalyzer', nuget: 'Buildalyzer', purpose: 'MSBuild + Roslyn integration', features: 'Analyze projects with Roslyn' },
      { name: 'ICSharpCode.CodeConverter', nuget: 'ICSharpCode.CodeConverter', purpose: 'Code conversion', features: 'C# to VB.NET and vice versa' }
    ],
    comparison: 'Microsoft.CodeAnalysis is the official Roslyn API for all C# compilation needs.'
  },

  SunamoRss: {
    description: 'RSS feed handling',
    alternatives: [
      { name: 'System.ServiceModel.Syndication', nuget: 'System.ServiceModel.Syndication', purpose: 'Built-in RSS/Atom support', features: 'Parse and create RSS/Atom feeds' },
      { name: 'CodeHollow.FeedReader', nuget: 'CodeHollow.FeedReader', purpose: 'Universal feed reader', features: 'RSS, Atom, auto-detection' },
      { name: 'SimpleFeedReader', nuget: 'SimpleFeedReader', purpose: 'Simple feed parsing', features: 'RSS 2.0, Atom 1.0' },
      { name: 'Microsoft.SyndicationFeed.ReaderWriter', nuget: 'Microsoft.SyndicationFeed.ReaderWriter', purpose: 'High-performance feed I/O', features: 'Streaming RSS/Atom reading' }
    ],
    comparison: 'CodeHollow.FeedReader for ease of use. Microsoft.SyndicationFeed for performance.'
  },

  SunamoRuleset: {
    description: 'Code analysis ruleset handling',
    alternatives: [
      { name: 'Microsoft.CodeAnalysis', nuget: 'Microsoft.CodeAnalysis', purpose: 'Roslyn analyzers', features: 'Code analysis rules, diagnostics' },
      { name: 'EditorConfig.Core', nuget: 'EditorConfig.Core', purpose: 'EditorConfig parsing', features: 'Code style rules' },
      { name: 'StyleCop.Analyzers', nuget: 'StyleCop.Analyzers', purpose: 'Style rules', features: 'Code style enforcement' }
    ],
    comparison: 'Modern .NET uses EditorConfig + Roslyn analyzers instead of legacy rulesets.'
  },

  SunamoSecurity: {
    description: 'Security utilities',
    alternatives: [
      { name: 'System.Security.Cryptography', nuget: 'System.Security.Cryptography', purpose: 'Cryptography APIs', features: 'Encryption, hashing, signing' },
      { name: 'IdentityModel', nuget: 'IdentityModel', purpose: 'OAuth/OIDC utilities', features: 'Token handling, discovery, validation' },
      { name: 'Microsoft.AspNetCore.Authentication', nuget: 'Microsoft.AspNetCore.Authentication', purpose: 'Authentication middleware', features: 'JWT, cookies, OAuth providers' },
      { name: 'BCrypt.Net', nuget: 'BCrypt.Net-Next', purpose: 'Password hashing', features: 'Secure password storage' }
    ],
    comparison: 'System.Security.Cryptography for crypto. IdentityModel for OAuth/OIDC. BCrypt for passwords.'
  },

  SunamoSelenium: {
    description: 'Selenium WebDriver utilities',
    alternatives: [
      { name: 'Selenium.WebDriver', nuget: 'Selenium.WebDriver', purpose: 'Browser automation', features: 'Control browsers, execute JavaScript, screenshots' },
      { name: 'Playwright', nuget: 'Microsoft.Playwright', purpose: 'Modern browser automation', features: 'Chromium, Firefox, WebKit, faster than Selenium' },
      { name: 'PuppeteerSharp', nuget: 'PuppeteerSharp', purpose: 'Headless Chrome automation', features: 'Chrome DevTools Protocol' },
      { name: 'Atata', nuget: 'Atata', purpose: 'Selenium wrapper', features: 'Page object pattern, fluent API' }
    ],
    comparison: 'Playwright is faster and more modern. Selenium has broader browser support and ecosystem.'
  },

  SunamoSerializer: {
    description: 'Serialization utilities',
    alternatives: [
      { name: 'System.Text.Json', nuget: 'System.Text.Json', purpose: 'JSON serialization', features: 'High performance, modern API' },
      { name: 'Newtonsoft.Json', nuget: 'Newtonsoft.Json', purpose: 'JSON.NET serializer', features: 'Mature, feature-rich JSON' },
      { name: 'MessagePack', nuget: 'MessagePack', purpose: 'Binary serialization', features: 'Fast, compact binary format' },
      { name: 'protobuf-net', nuget: 'protobuf-net', purpose: 'Protocol Buffers', features: 'Google protocol buffers for .NET' },
      { name: 'YamlDotNet', nuget: 'YamlDotNet', purpose: 'YAML serialization', features: 'YAML parsing and emitting' }
    ],
    comparison: 'Choose based on format: System.Text.Json for JSON, MessagePack for binary, YamlDotNet for YAML.'
  },

  SunamoShared: {
    description: 'Shared utilities and common code',
    alternatives: [
      { name: 'CommunityToolkit.Common', nuget: 'CommunityToolkit.Common', purpose: 'Common utilities', features: 'Helpers, extensions, guards' },
      { name: 'Ardalis.GuardClauses', nuget: 'Ardalis.GuardClauses', purpose: 'Guard clauses', features: 'Argument validation' },
      { name: 'Dawn.Guard', nuget: 'Dawn.Guard', purpose: 'Guard library', features: 'Fluent validation, guard clauses' }
    ],
    comparison: 'Use guard libraries for common validation. CommunityToolkit for general utilities.'
  },

  SunamoStopwatch: {
    description: 'Performance timing utilities',
    alternatives: [
      { name: 'System.Diagnostics.Stopwatch', nuget: 'System.Diagnostics.Debug', purpose: 'Built-in stopwatch', features: 'High-resolution timing, elapsed time' },
      { name: 'BenchmarkDotNet', nuget: 'BenchmarkDotNet', purpose: 'Benchmarking framework', features: 'Accurate performance measurements, statistical analysis' },
      { name: 'MiniProfiler', nuget: 'MiniProfiler', purpose: 'Profiling library', features: 'Web request timing, database profiling' },
      { name: 'System.Diagnostics.Activity', nuget: 'System.Diagnostics.DiagnosticSource', purpose: 'Distributed tracing', features: 'Activity tracking, correlation' }
    ],
    comparison: 'Stopwatch for simple timing. BenchmarkDotNet for accurate benchmarks. MiniProfiler for profiling.'
  },

  SunamoString: {
    description: 'String manipulation utilities',
    alternatives: [
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'String humanization', features: 'Pluralize, truncate, case conversion, inflection' },
      { name: 'System.String', nuget: 'System.Runtime', purpose: 'Built-in string methods', features: 'Split, Join, Replace, Substring, Trim' },
      { name: 'StringExtensions', nuget: 'StringExtensions', purpose: 'String extension methods', features: 'Additional string utilities' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Collection/string LINQ', features: 'ToDelimitedString, string joining' }
    ],
    comparison: 'Built-in string methods cover basics. Humanizer for advanced string manipulation and display.'
  },

  SunamoStringFormat: {
    description: 'String formatting utilities',
    alternatives: [
      { name: 'System.String.Format', nuget: 'System.Runtime', purpose: 'Built-in formatting', features: 'Composite formatting, string interpolation' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Human-readable formatting', features: 'Date, number, enum formatting' },
      { name: 'SmartFormat', nuget: 'SmartFormat.Net', purpose: 'Advanced string formatting', features: 'Templates, conditional formatting, lists' },
      { name: 'String.Format.Extensions', nuget: 'String.Format.Extensions', purpose: 'Format extensions', features: 'Named placeholders' }
    ],
    comparison: 'String interpolation ($"") is modern standard. SmartFormat for complex templates.'
  },

  SunamoStringGetLines: {
    description: 'String line manipulation',
    alternatives: [
      { name: 'System.String', nuget: 'System.Runtime', purpose: 'Split by line breaks', features: 'Split("\\n"), Environment.NewLine' },
      { name: 'System.IO.StringReader', nuget: 'System.Runtime', purpose: 'Read string as lines', features: 'ReadLine() method' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Line operations', features: 'Split, batch operations' }
    ],
    comparison: 'StringReader.ReadLine() or string.Split() handle most line operations.'
  },

  SunamoStringGetString: {
    description: 'String extraction utilities',
    alternatives: [
      { name: 'System.String', nuget: 'System.Runtime', purpose: 'Substring operations', features: 'Substring, IndexOf, LastIndexOf' },
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Pattern extraction', features: 'Match groups, captures' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'String transformations', features: 'Truncate, extract patterns' }
    ],
    comparison: 'Built-in string methods for simple extraction. Regex for pattern-based extraction.'
  },

  SunamoStringJoin: {
    description: 'String joining utilities',
    alternatives: [
      { name: 'System.String.Join', nuget: 'System.Runtime', purpose: 'Built-in string joining', features: 'Join collections with separators' },
      { name: 'System.Text.StringBuilder', nuget: 'System.Runtime', purpose: 'Efficient string building', features: 'Append, AppendJoin methods' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'ToDelimitedString', features: 'LINQ-based string joining' }
    ],
    comparison: 'String.Join() is the standard. StringBuilder for large-scale concatenation.'
  },

  SunamoStringJoinPairs: {
    description: 'Key-value pair joining',
    alternatives: [
      { name: 'System.String.Join', nuget: 'System.Runtime', purpose: 'Join with formatting', features: 'Format key-value pairs' },
      { name: 'System.Linq', nuget: 'System.Linq', purpose: 'Select and join', features: 'Select(x => $"{x.Key}={x.Value}") + String.Join' },
      { name: 'QueryString helpers', nuget: 'Microsoft.AspNetCore.WebUtilities', purpose: 'Query string building', features: 'QueryHelpers.AddQueryString' }
    ],
    comparison: 'LINQ Select + String.Join handles most pair joining scenarios.'
  },

  SunamoStringParts: {
    description: 'String parts and splitting',
    alternatives: [
      { name: 'System.String.Split', nuget: 'System.Runtime', purpose: 'Built-in splitting', features: 'Split by char, string, regex' },
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Pattern-based splitting', features: 'Regex.Split()' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Advanced splitting', features: 'Split, Batch operations' }
    ],
    comparison: 'String.Split() covers most splitting needs. Regex.Split for complex patterns.'
  },

  SunamoStringReplace: {
    description: 'String replacement utilities',
    alternatives: [
      { name: 'System.String.Replace', nuget: 'System.Runtime', purpose: 'Built-in replacement', features: 'Replace string, char occurrences' },
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Pattern replacement', features: 'Regex.Replace with patterns' },
      { name: 'System.Text.StringBuilder', nuget: 'System.Runtime', purpose: 'Efficient replacement', features: 'StringBuilder.Replace for multiple operations' }
    ],
    comparison: 'String.Replace() for simple cases. Regex.Replace for patterns. StringBuilder for multiple replacements.'
  },

  SunamoStringSplit: {
    description: 'String splitting utilities',
    alternatives: [
      { name: 'System.String.Split', nuget: 'System.Runtime', purpose: 'Built-in splitting', features: 'Split by separators, options' },
      { name: 'System.MemoryExtensions', nuget: 'System.Memory', purpose: 'Span-based splitting', features: 'High performance, zero-allocation splitting' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Advanced splitting', features: 'Split into chunks' }
    ],
    comparison: 'String.Split() is standard. Span<char>.Split() for performance-critical code.'
  },

  SunamoStringSubstring: {
    description: 'Substring utilities',
    alternatives: [
      { name: 'System.String.Substring', nuget: 'System.Runtime', purpose: 'Built-in substring', features: 'Extract substrings by index' },
      { name: 'System.ReadOnlySpan', nuget: 'System.Memory', purpose: 'Zero-allocation slicing', features: 'Span slicing without allocations' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Smart truncation', features: 'Truncate, left, right, middle' }
    ],
    comparison: 'Substring() for standard use. ReadOnlySpan<char> for performance. Humanizer.Truncate for display.'
  },

  SunamoStringTrim: {
    description: 'String trimming utilities',
    alternatives: [
      { name: 'System.String', nuget: 'System.Runtime', purpose: 'Built-in trimming', features: 'Trim, TrimStart, TrimEnd' },
      { name: 'System.MemoryExtensions', nuget: 'System.Memory', purpose: 'Span trimming', features: 'High-performance trim operations' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Smart trimming', features: 'Remove diacritics, special chars' }
    ],
    comparison: 'Built-in Trim methods cover most needs. Humanizer for advanced text cleanup.'
  },

  SunamoTest: {
    description: 'Testing utilities',
    alternatives: [
      { name: 'xUnit', nuget: 'xunit', purpose: 'Modern test framework', features: 'Theories, fixtures, parallel execution' },
      { name: 'NUnit', nuget: 'NUnit', purpose: 'Mature test framework', features: 'Rich assertions, test cases, setup/teardown' },
      { name: 'MSTest', nuget: 'MSTest.TestFramework', purpose: 'Microsoft test framework', features: 'VS integration, data-driven tests' },
      { name: 'FluentAssertions', nuget: 'FluentAssertions', purpose: 'Fluent assertion library', features: 'Readable assertions, better error messages' },
      { name: 'Moq', nuget: 'Moq', purpose: 'Mocking framework', features: 'Create test doubles, verify interactions' }
    ],
    comparison: 'xUnit is most modern. FluentAssertions for better assertions. Moq for mocking.'
  },

  SunamoText: {
    description: 'Text processing utilities',
    alternatives: [
      { name: 'System.Text', nuget: 'System.Runtime', purpose: 'Built-in text classes', features: 'StringBuilder, Encoding, string operations' },
      { name: 'Humanizer', nuget: 'Humanizer', purpose: 'Text humanization', features: 'Pluralization, truncation, casing' },
      { name: 'TextCopy', nuget: 'TextCopy', purpose: 'Clipboard text operations', features: 'Cross-platform text copy/paste' },
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Pattern matching', features: 'Text parsing and transformation' }
    ],
    comparison: 'System.Text + Humanizer cover most text processing needs.'
  },

  SunamoTextIndexing: {
    description: 'Text indexing and search',
    alternatives: [
      { name: 'Lucene.Net', nuget: 'Lucene.Net', purpose: 'Full-text search engine', features: 'Indexing, searching, analyzers, scoring' },
      { name: 'Elasticsearch.Net', nuget: 'Elasticsearch.Net', purpose: 'Elasticsearch client', features: 'Distributed search, aggregations' },
      { name: 'Azure.Search.Documents', nuget: 'Azure.Search.Documents', purpose: 'Azure Cognitive Search', features: 'Cloud search service' },
      { name: 'RavenDB.Client', nuget: 'RavenDB.Client', purpose: 'Document database with search', features: 'Full-text search, indexing' }
    ],
    comparison: 'Lucene.Net for embedded search. Elasticsearch for distributed search.'
  },

  SunamoTextOutputGenerator: {
    description: 'Text output generation',
    alternatives: [
      { name: 'Scriban', nuget: 'Scriban', purpose: 'Fast template engine', features: 'Liquid-like syntax, safe scripting' },
      { name: 'RazorEngine', nuget: 'RazorEngine', purpose: 'Razor templating', features: 'Razor syntax outside ASP.NET' },
      { name: 'Handlebars.Net', nuget: 'Handlebars.Net', purpose: 'Handlebars templates', features: 'Logic-less templates' },
      { name: 'Stubble', nuget: 'Stubble.Core', purpose: 'Mustache templates', features: 'Fast mustache implementation' },
      { name: 'T4', nuget: 'Microsoft.VisualStudio.TextTemplating', purpose: 'T4 templates', features: 'Code generation templates' }
    ],
    comparison: 'Scriban for modern templates. RazorEngine for Razor syntax. Handlebars/Stubble for logic-less.'
  },

  SunamoThisApp: {
    description: 'Application information utilities',
    alternatives: [
      { name: 'System.Reflection.Assembly', nuget: 'System.Reflection', purpose: 'Assembly information', features: 'Version, location, attributes' },
      { name: 'System.Diagnostics.Process', nuget: 'System.Diagnostics.Process', purpose: 'Current process info', features: 'GetCurrentProcess(), modules, memory' },
      { name: 'System.AppDomain', nuget: 'System.Runtime', purpose: 'Application domain', features: 'Base directory, friendly name' },
      { name: 'System.Environment', nuget: 'System.Runtime', purpose: 'Environment information', features: 'OS version, machine name, user name' }
    ],
    comparison: 'Built-in BCL types provide comprehensive application information.'
  },

  SunamoThread: {
    description: 'Threading utilities',
    alternatives: [
      { name: 'System.Threading', nuget: 'System.Threading', purpose: 'Built-in threading', features: 'Thread, ThreadPool, synchronization primitives' },
      { name: 'System.Threading.Tasks', nuget: 'System.Threading.Tasks', purpose: 'Task-based async', features: 'Task, async/await, parallel operations' },
      { name: 'Nito.AsyncEx', nuget: 'Nito.AsyncEx', purpose: 'Async utilities', features: 'AsyncLock, AsyncManualResetEvent, AsyncContext' },
      { name: 'System.Threading.Channels', nuget: 'System.Threading.Channels', purpose: 'Producer/consumer channels', features: 'Thread-safe data passing' }
    ],
    comparison: 'Modern async/await is preferred. Use Task instead of Thread. Nito.AsyncEx for advanced scenarios.'
  },

  SunamoThreading: {
    description: 'Advanced threading utilities',
    alternatives: [
      { name: 'System.Threading.Tasks.Dataflow', nuget: 'System.Threading.Tasks.Dataflow', purpose: 'Dataflow library', features: 'Actor model, pipelines, parallel processing' },
      { name: 'Nito.AsyncEx', nuget: 'Nito.AsyncEx', purpose: 'Async primitives', features: 'Async-compatible synchronization' },
      { name: 'System.Threading.Channels', nuget: 'System.Threading.Channels', purpose: 'High-performance channels', features: 'Producer-consumer patterns' },
      { name: 'Parallel Extensions', nuget: 'System.Threading.Tasks.Parallel', purpose: 'Parallel operations', features: 'Parallel.For, Parallel.ForEach, PLINQ' }
    ],
    comparison: 'Use async/await + Channels for most scenarios. Dataflow for complex pipelines.'
  },

  SunamoTidy: {
    description: 'HTML Tidy integration',
    alternatives: [
      { name: 'TidyManaged', nuget: 'TidyManaged', purpose: 'HTML Tidy wrapper', features: 'Clean and validate HTML' },
      { name: 'HtmlAgilityPack', nuget: 'HtmlAgilityPack', purpose: 'HTML parsing and fixing', features: 'Tolerant HTML parser, DOM manipulation' },
      { name: 'AngleSharp', nuget: 'AngleSharp', purpose: 'Standards-compliant parser', features: 'HTML5 parsing, validation' }
    ],
    comparison: 'HtmlAgilityPack for HTML parsing. AngleSharp for standards compliance.'
  },

  SunamoToUnixLineEnding: {
    description: 'Line ending conversion utilities',
    alternatives: [
      { name: 'System.String.Replace', nuget: 'System.Runtime', purpose: 'Built-in replacement', features: 'Replace("\\r\\n", "\\n")' },
      { name: 'System.Text.RegularExpressions', nuget: 'System.Text.RegularExpressions', purpose: 'Pattern-based conversion', features: 'Regex.Replace for line endings' },
      { name: 'EditorConfig', nuget: 'EditorConfig.Core', purpose: 'Editor configuration', features: 'Configure line endings per file type' }
    ],
    comparison: 'Simple string replacement handles line ending conversion. EditorConfig for standardization.'
  },

  SunamoTwoWayDictionary: {
    description: 'Bidirectional dictionary',
    alternatives: [
      { name: 'BidirectionalMap', nuget: 'BidirectionalMap', purpose: 'Two-way dictionary', features: 'Lookup by key or value' },
      { name: 'BiDictionary', nuget: 'BiDictionary', purpose: 'Bidirectional mapping', features: 'Symmetric key-value lookup' },
      { name: 'System.Collections.Generic.Dictionary', nuget: 'System.Collections', purpose: 'Manual implementation', features: 'Maintain two dictionaries' }
    ],
    comparison: 'BidirectionalMap or BiDictionary for ready-made solutions. Two Dictionary instances for custom needs.'
  },

  SunamoTypes: {
    description: 'Type utilities',
    alternatives: [
      { name: 'System.Type', nuget: 'System.Runtime', purpose: 'Built-in type reflection', features: 'Type information, metadata' },
      { name: 'System.Reflection', nuget: 'System.Reflection', purpose: 'Reflection APIs', features: 'Type inspection, member access' },
      { name: 'Nullable', nuget: 'Nullable', purpose: 'Nullable reference types', features: 'Null safety attributes' },
      { name: 'TypeShape', nuget: 'TypeShape', purpose: 'Generic type programming', features: 'Type-level programming utilities' }
    ],
    comparison: 'System.Type and System.Reflection cover most type operations.'
  },

  SunamoUnderscore: {
    description: 'Underscore.js-like utilities for .NET',
    alternatives: [
      { name: 'System.Linq', nuget: 'System.Linq', purpose: 'LINQ query operators', features: 'Functional collection operations' },
      { name: 'MoreLINQ', nuget: 'morelinq', purpose: 'Extended LINQ', features: '50+ additional operators' },
      { name: 'LanguageExt', nuget: 'LanguageExt.Core', purpose: 'Functional programming', features: 'Functional utilities, monads, immutable collections' },
      { name: 'NetFabric.Hyperlinq', nuget: 'NetFabric.Hyperlinq', purpose: 'Performance LINQ', features: 'Zero-allocation LINQ' }
    ],
    comparison: 'LINQ provides functional utilities built-in. MoreLINQ/LanguageExt for additional operations.'
  },

  SunamoUri: {
    description: 'URI utilities',
    alternatives: [
      { name: 'System.Uri', nuget: 'System.Runtime', purpose: 'Built-in URI handling', features: 'Parse, build, validate URIs' },
      { name: 'Flurl', nuget: 'Flurl', purpose: 'Fluent URL builder', features: 'Build URLs, query strings, URL encoding' },
      { name: 'Microsoft.AspNetCore.WebUtilities', nuget: 'Microsoft.AspNetCore.WebUtilities', purpose: 'Web utilities', features: 'QueryHelpers, URL encoding/decoding' },
      { name: 'UriBuilder', nuget: 'System.Runtime', purpose: 'Built-in URI builder', features: 'Construct URIs programmatically' }
    ],
    comparison: 'System.Uri for basic operations. Flurl for fluent URL building.'
  },

  SunamoUriWebServices: {
    description: 'Web service URI utilities',
    alternatives: [
      { name: 'Flurl', nuget: 'Flurl', purpose: 'URL building for APIs', features: 'Query parameters, path segments' },
      { name: 'RestSharp', nuget: 'RestSharp', purpose: 'REST client', features: 'Request building, URL templates' },
      { name: 'Refit', nuget: 'Refit', purpose: 'Type-safe REST client', features: 'Automatic URL construction from interfaces' }
    ],
    comparison: 'Flurl for manual URL building. Refit for type-safe API clients.'
  },

  SunamoValues: {
    description: 'Value object utilities',
    alternatives: [
      { name: 'ValueOf', nuget: 'ValueOf', purpose: 'Value objects', features: 'Type-safe value wrappers, implicit conversions' },
      { name: 'System.ValueTuple', nuget: 'System.ValueTuple', purpose: 'Built-in value tuples', features: 'Lightweight value types' },
      { name: 'StronglyTypedId', nuget: 'StronglyTypedId', purpose: 'Strongly-typed IDs', features: 'Type-safe identifiers' },
      { name: 'Vogen', nuget: 'Vogen', purpose: 'Value object generator', features: 'Source generator for value objects' }
    ],
    comparison: 'ValueOf or Vogen for domain-driven design value objects. ValueTuple for simple cases.'
  },

  SunamoVcf: {
    description: 'vCard (VCF) file handling',
    alternatives: [
      { name: 'Thought.vCards', nuget: 'Thought.vCards', purpose: 'vCard library', features: 'Read, write, parse vCard files' },
      { name: 'VCardLib', nuget: 'VCardLib', purpose: 'vCard processing', features: 'vCard 2.1, 3.0, 4.0 support' },
      { name: 'MixERP.Net.VCards', nuget: 'MixERP.Net.VCards', purpose: 'vCard parser', features: 'Contact card parsing' }
    ],
    comparison: 'Thought.vCards is the most mature vCard library for .NET.'
  },

  SunamoWikipedia: {
    description: 'Wikipedia API integration',
    alternatives: [
      { name: 'WikiClientLibrary', nuget: 'WikiClientLibrary', purpose: 'MediaWiki API client', features: 'Wikipedia, Wikia, WikiData access' },
      { name: 'WikipediaNET', nuget: 'WikipediaNET', purpose: 'Wikipedia queries', features: 'Search, page content, links' },
      { name: 'HtmlAgilityPack', nuget: 'HtmlAgilityPack', purpose: 'Scrape Wikipedia pages', features: 'HTML parsing (for scraping)' }
    ],
    comparison: 'WikiClientLibrary for comprehensive MediaWiki API access. WikipediaNET for simpler queries.'
  },

  SunamoWinStd: {
    description: 'Windows standard operations',
    alternatives: [
      { name: 'PInvoke.Kernel32', nuget: 'PInvoke.Kernel32', purpose: 'Windows API access', features: 'Type-safe P/Invoke signatures' },
      { name: 'Vanara', nuget: 'Vanara.PInvoke', purpose: 'Comprehensive Windows APIs', features: 'Complete Win32 API coverage' },
      { name: 'System.Runtime.InteropServices', nuget: 'System.Runtime.InteropServices', purpose: 'Built-in interop', features: 'P/Invoke, COM interop' }
    ],
    comparison: 'Vanara provides the most complete Windows API coverage with type safety.'
  },

  SunamoXlfKeys: {
    description: 'XLF localization key utilities',
    alternatives: [
      { name: 'Microsoft.Extensions.Localization', nuget: 'Microsoft.Extensions.Localization', purpose: 'Localization framework', features: 'Resource strings, cultures' },
      { name: 'XliffParser', nuget: 'XliffParser', purpose: 'XLIFF file parsing', features: 'Read, write XLIFF files' },
      { name: 'Multilingual.NET', nuget: 'Multilingual.NET', purpose: 'Localization utilities', features: 'XLIFF support, translation workflows' }
    ],
    comparison: 'XliffParser for XLIFF files. Microsoft.Extensions.Localization for general localization.'
  },

  SunamoXliffParser: {
    description: 'XLIFF file parsing',
    alternatives: [
      { name: 'XliffParser', nuget: 'XliffParser', purpose: 'XLIFF file handling', features: 'Parse and create XLIFF 1.2/2.0 files' },
      { name: 'Localization.Xliff', nuget: 'Localization.Xliff', purpose: 'XLIFF integration', features: 'XLIFF provider for .NET localization' },
      { name: 'System.Xml.Linq', nuget: 'System.Xml.Linq', purpose: 'Manual XML parsing', features: 'Parse XLIFF as XML' }
    ],
    comparison: 'XliffParser is the standard library for XLIFF file operations.'
  },

  SunamoXml: {
    description: 'XML utilities',
    alternatives: [
      { name: 'System.Xml.Linq', nuget: 'System.Xml.Linq', purpose: 'LINQ to XML', features: 'XDocument, XElement, modern XML API' },
      { name: 'System.Xml', nuget: 'System.Xml', purpose: 'Built-in XML', features: 'XmlDocument, XmlReader, XmlWriter' },
      { name: 'System.Xml.Serialization', nuget: 'System.Xml.XmlSerializer', purpose: 'XML serialization', features: 'Object to XML mapping' },
      { name: 'XmlDocument', nuget: 'System.Xml.XmlDocument', purpose: 'DOM-based XML', features: 'DOM manipulation' }
    ],
    comparison: 'System.Xml.Linq (LINQ to XML) is the modern approach. XmlSerializer for object mapping.'
  },

  SunamoYaml: {
    description: 'YAML utilities',
    alternatives: [
      { name: 'YamlDotNet', nuget: 'YamlDotNet', purpose: 'YAML parser/emitter', features: 'Serialize, deserialize, schema validation' },
      { name: 'SharpYaml', nuget: 'SharpYaml', purpose: 'YAML library', features: 'YAML 1.2 support, anchors, aliases' },
      { name: 'Microsoft.Extensions.Configuration.Yaml', nuget: 'Microsoft.Extensions.Configuration.Yaml', purpose: 'YAML configuration', features: 'YAML config provider for .NET' }
    ],
    comparison: 'YamlDotNet is the most popular and actively maintained YAML library for .NET.'
  },

  SunamoYouTube: {
    description: 'YouTube API integration',
    alternatives: [
      { name: 'Google.Apis.YouTube.v3', nuget: 'Google.Apis.YouTube.v3', purpose: 'Official YouTube Data API', features: 'Videos, playlists, channels, search' },
      { name: 'YoutubeExplode', nuget: 'YoutubeExplode', purpose: 'YouTube scraping library', features: 'Download videos, extract metadata, no API key needed' },
      { name: 'VideoLibrary', nuget: 'VideoLibrary', purpose: 'YouTube downloader', features: 'Download YouTube videos programmatically' }
    ],
    comparison: 'Google.Apis.YouTube for official API access. YoutubeExplode for downloading without API keys.'
  }
};

const baseDir = 'E:/vs/Projects/PlatformIndependentNuGetPackages';

// Get all Sunamo package directories
const packageDirs = require('fs').readdirSync(baseDir)
  .filter(dir => dir.startsWith('Sunamo'))
  .map(dir => ({ name: dir, path: path.join(baseDir, dir) }));

console.log(`Found ${packageDirs.length} Sunamo packages to process`);

let processed = 0;
let created = 0;
let skipped = 0;
let errors = [];

for (const pkg of packageDirs) {
  processed++;
  const packageName = pkg.name;

  console.log(`\nProcessing ${processed}/${packageDirs.length}: ${packageName}...`);

  const alternativesData = packageAlternatives[packageName];

  if (!alternativesData) {
    console.log(`  ⚠ No alternatives defined for ${packageName} - using generic template`);
    skipped++;
    continue;
  }

  // Find the inner package directory (e.g., SunamoString/SunamoString/)
  let innerDir = path.join(pkg.path, packageName);
  if (!fs.existsSync(innerDir)) {
    // Some packages might have different structure
    innerDir = pkg.path;
  }

  const outputPath = path.join(innerDir, 'nuget_alternatives.md');

  // Generate markdown content
  let content = `# NuGet Alternatives to ${packageName}\n\n`;
  content += `This document lists popular NuGet packages that provide similar functionality to ${packageName}.\n\n`;
  content += `## Overview\n\n`;
  content += `${alternativesData.description}\n\n`;
  content += `## Alternative Packages\n\n`;

  for (const alt of alternativesData.alternatives) {
    content += `### ${alt.name}\n`;
    content += `- **NuGet**: ${alt.nuget}\n`;
    content += `- **Purpose**: ${alt.purpose}\n`;
    content += `- **Key Features**: ${alt.features}\n\n`;
  }

  content += `## Comparison Notes\n\n`;
  content += `${alternativesData.comparison}\n\n`;

  content += `## Choosing an Alternative\n\n`;
  content += `Consider these alternatives based on your specific needs:\n`;
  for (let i = 0; i < Math.min(3, alternativesData.alternatives.length); i++) {
    content += `- **${alternativesData.alternatives[i].name}**: ${alternativesData.alternatives[i].purpose}\n`;
  }

  try {
    fs.writeFileSync(outputPath, content, 'utf8');
    console.log(`  ✓ Created: ${outputPath}`);
    created++;
  } catch (error) {
    console.log(`  ✗ Error creating file: ${error.message}`);
    errors.push({ package: packageName, error: error.message });
  }
}

console.log('\n' + '='.repeat(80));
console.log('SUMMARY');
console.log('='.repeat(80));
console.log(`Total packages processed: ${processed}`);
console.log(`Files created: ${created}`);
console.log(`Skipped (no data): ${skipped}`);
console.log(`Errors: ${errors.length}`);

if (errors.length > 0) {
  console.log('\nErrors encountered:');
  errors.forEach(e => console.log(`  - ${e.package}: ${e.error}`));
}
