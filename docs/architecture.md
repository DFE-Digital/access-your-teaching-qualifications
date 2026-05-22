# Architecture

Both services are monolithic Rails apps built with the GOV.UK Design System. They share a single repository, database, and deployment pipeline. See [routing two services](routing-two-services.md) for how requests are routed to the correct service.

## C4 diagrams

We create architecture views of the application using the C4 diagramming method.

The diagram code can be found [here](aytq-ctr-container-view.dsl) and rendered [here](https://structurizr.com/dsl) in Structurizr, Mermaid or PlantUML etc.

## Architecture Decision Records (ADRs)

We keep track of architecture decisions in [Architecture Decision Records (ADRs)](/adr/).

We use `rladr` to generate the boilerplate for new records:

```bash
bin/bundle exec rladr new title
```
