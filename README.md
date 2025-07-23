# Paywall System Modernization Repository

Repository following Applied AI transformation structure: Source → Tobe → Gaps → Transformation Assets

## Quick Start
- **source/**: Current legacy system artifacts
- **tobe/**: Target modern architecture 
- **gaps/**: Identified transformation gaps
- **transformation-assets/**: Reusable transformation tools

## Comprehensive AI-Driven Legacy Modernization Prompt

Use this prompt to recreate a similar modernization repository for your project:

```
I need to create a complete legacy system modernization repository following the Applied AI transformation model with this structure:

Source (AS-IS) → To-be (Target) → Gaps (Analysis) → Transformation Assets

The repository should document a mainframe COBOL/CICS/DB2 customer registration system for a paywall application.

Please help me:

1. Create a complete legacy customer registration system with ALL associated artifacts:
   - COBOL programs (main registration program and CICS UI program)
   - DB2 DDL schemas (all tables, sequences, triggers, stored procedures)
   - JCL for compilation and batch processing
   - CICS BMS maps and transaction definitions
   - All supporting components

2. Organize the repository following this exact structure:
   - source/ (AS-IS artifacts)
   - tobe/ (Target state)
   - gaps/ (Gap analysis)
   - transformation-assets/ (Reusable components)

   Within each main directory, create these artifact categories:
   - bnf-grammar/
   - enterprise-architecture/
   - data-schema/
   - application-topology/
   - business-functions-processes/
   - skills/
   - organisation/

3. Populate the source/ directory with comprehensive legacy artifacts including:
   - BNF grammar definitions for COBOL, JCL, CICS, DB2
   - Enterprise architecture diagrams and integration points
   - Complete data schemas with copybooks and VSAM definitions
   - Application topology including job dependencies and network config
   - Business rules, process flows, and error codes
   - Skills matrices and training documentation
   - Organization structure and communication plans

4. Create modern architecture diagrams and specifications in appropriate formats:
   - Mermaid diagrams for visual topology (renders in GitHub)
   - OpenAPI specs for REST APIs
   - AsyncAPI specs for event-driven architecture
   - Kubernetes manifests for deployment
   - C4 model diagrams for architecture documentation

5. Generate scripts to:
   - Create the complete directory structure
   - Generate all artifact files with realistic content
   - Set up Git repository
   - Push to GitHub repository at: https://github.com/[USERNAME]/[REPO-NAME]

Please provide:
- All COBOL/JCL/DB2/CICS code as complete, runnable programs
- Comprehensive documentation in modern formats (Mermaid, OpenAPI, etc.)
- Bash/Ruby scripts to automate the entire setup
- Commands to execute everything without manual editing

The goal is to create a production-ready repository that demonstrates both legacy complexity and modern target architecture, suitable for AI-driven analysis and transformation.
```

### To customize for your project:

1. **Replace the business domain**: Change "customer registration system for a paywall" to your system
2. **Modify the tech stack**: Update COBOL/CICS/DB2 to your legacy stack
3. **Update GitHub details**: Change [USERNAME]/[REPO-NAME] to your repository
4. **Adjust artifact categories**: Modify the seven categories if needed
5. **Specify your target architecture**: Update the modern tech choices (Kubernetes, Mermaid, etc.)

This single prompt will generate everything needed for a comprehensive modernization repository.

## Repository Contents

### Source (Legacy) Artifacts
- COBOL programs with embedded SQL
- DB2 database schemas and stored procedures
- JCL for batch processing and compilation
- CICS BMS maps and transaction definitions
- Complete system documentation

### Target (Modern) Architecture
- Microservices design with Spring Boot, Node.js, Go
- Event-driven architecture with Kafka
- Kubernetes deployment manifests
- REST APIs (OpenAPI 3.0)
- CI/CD pipeline definitions

### Visualizations
- Mermaid diagrams for architecture visualization
- C4 model for different architecture levels
- Process flows and sequence diagrams
- Deployment topology diagrams

See [as_is_system_overview.md](as_is_system_overview.md) for complete repository structure visualization.

## Getting Started

1. Clone this repository
2. Navigate through the source/ directory to understand the legacy system
3. Review the tobe/ directory for the target architecture
4. Examine the gaps/ directory to understand transformation challenges
5. Use transformation-assets/ for reusable migration tools

## Technologies

### Legacy Stack
- COBOL
- CICS
- DB2 z/OS
- JCL
- VSAM
- MQ Series

### Modern Stack
- Spring Boot / Node.js / Go
- PostgreSQL
- Apache Kafka
- Kubernetes / Istio
- React
- AWS/Azure/GCP
