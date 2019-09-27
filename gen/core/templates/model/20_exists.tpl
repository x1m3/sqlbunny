{{- $modelNameSingular := .Model.Name | singular | titleCase -}}
{{- $colDefs := sqlColDefinitions .Model.Columns .Model.PrimaryKey.Columns -}}
{{- $pkNames := $colDefs.Names | stringMap .StringFuncs.camelCase | stringMap .StringFuncs.replaceReserved -}}
{{- $pkTypes := typesGo $colDefs.Types }}
{{- $pkArgs := joinSlices " " $pkNames $pkTypes | join ", "}}
{{- $schemaModel := .Model.Name | schemaModel}}
// {{$modelNameSingular}}Exists checks if the {{$modelNameSingular}} row exists.
func {{$modelNameSingular}}Exists(ctx context.Context, {{$pkArgs}}) (bool, error) {
	var exists bool
	sql := "select exists(select 1 from {{$schemaModel}} where {{if .Dialect.IndexPlaceholders}}{{whereClause .LQ .RQ 1 .Model.PrimaryKey.Columns}}{{else}}{{whereClause .LQ .RQ 0 .Model.PrimaryKey.Columns}}{{end}} limit 1)"

	row := bunny.QueryRow(ctx, sql, {{$pkNames | join ", "}})

	err := row.Scan(&exists)
	if err != nil {
		return false, errors.Errorf("{{.PkgName}}: unable to check if {{.Model.Name}} exists: %w", err)
	}

	return exists, nil
}
