# StarRocks

StarRocks is a MySQL-compatible OLAP database. It uses the same named-parameter syntax as MySQL.

Arguments use `:name` placeholders.

Name the parameters by adding comments before the statement:

```sql
-- :name1 (text) = default arg
-- :name2 (int)
-- :name3 (int)
SELECT * FROM users WHERE name = :name1 AND age > :name2;
```

## Receiving an S3Object as a script parameter

Declare the arg with type `(s3object)`. Windmill renders an S3 file picker for
it, downloads the file, and binds it as JSON text — Parquet/CSV files are
decoded server-side into a JSON array of records, JSON/JSONL pass through.
Consume with `JSON_TABLE`:

```sql
-- :file (s3object)
SELECT id, name
FROM JSON_TABLE(:file, '$[*]'
  COLUMNS (id INT PATH '$.id', name VARCHAR(200) PATH '$.name')
) AS r;
```

## Streaming query results to S3

Add a `-- s3` directive at the top of the script to stream the result set to S3
instead of returning rows. Windmill writes the file and returns its `S3Object`
as the script result.

```sql
-- s3 prefix=exports/users format=parquet
SELECT id, name FROM users;
```

All keys are optional: `prefix` (object key prefix), `storage` (named storage —
omit to use the workspace default), `format` (`json` (default), `parquet`, or
`csv`).

## Default port

StarRocks listens on port **9030** for MySQL-protocol connections (not 3306).
