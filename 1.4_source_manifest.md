# Source manifest

## OneLake static files

Upload to:

```text
Files/source/onelake_static/
```

Files:

```text
dim_terminal.csv
dim_product.csv
```

## Dataverse

Table:

```text
customer_contracts
```

Primary key:

```text
contract_id
```

Incremental column:

```text
last_modified_utc
```

## SharePoint List

List:

```text
TerminalOperationsMovements
```

Primary key:

```text
movement_id
```

Incremental column:

```text
last_modified_utc
```
