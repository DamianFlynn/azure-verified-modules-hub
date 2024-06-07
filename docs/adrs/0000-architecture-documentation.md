# 1. Architecture documentation

Date: 2024-06-06

## Status

Accepted

## Context

We need to apply template for architecture communication and documentation.

- What should you document/communicate about your architecture?
- How should you document/communicate?

## Decision

We will use [arc42](https://docs.arc42.org/home/) which answers the two questions in a pragmatic way.

![arc42](./assets/0000%20arc42%20Template%20Overview%20V8.png)

The template defines multiple sections where the different diagram types provided by the C4 model can be used. The following table shows how the C4 diagram types can be mapped to the arc42 template sections.

| arc42 template section | C4 diagram type                                     |
| ---------------------- | --------------------------------------------------- |
| Context and Scope      | System context diagram</br>System landscape diagram |
| Building Block View    | Container diagram</br>Component diagram             |
| Runtime View           | Dynamic diagram                                     |
| Deployment View        | Deployment diagram                                  |

Additionally, Code diagrams can be added to the building block, runtime or deployment view, but should only be added if they provide value to the reader.

Such low-level diagrams contain a lot of detail, which tend to become obsolete fast and thus need a lot of maintenance to keep them up to date. To minimize these efforts, they should be generated from code automatically. This also applies to component diagrams. How component diagrams, and other elements of the Structurizr model, can be generated from code.

## Consequences

See Michael Nygard's article, linked above. For a lightweight ADR toolset, see Nat Pryce's [adr-tools](https://github.com/npryce/adr-tools).
