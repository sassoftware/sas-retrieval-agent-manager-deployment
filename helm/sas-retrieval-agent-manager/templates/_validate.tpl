{{- define "validatePasswords" -}}
{{- if not .Values.users.skipPasswordValidation | default false -}}
{{- $errors := list -}}

{{/* ── Simple non-empty checks ── */}}
{{- if not .Values.users.postgrest.password                  }}{{- $errors = append $errors "users.postgrest.password is empty"                       }}{{- end }}
{{- if not .Values.users.database.admin.password             }}{{- $errors = append $errors "users.database.admin.password is empty"                  }}{{- end }}
{{- if not .Values.users.monitoring.password                 }}{{- $errors = append $errors "users.monitoring.password is empty"                      }}{{- end }}
{{- if not .Values.users.embedding.password                  }}{{- $errors = append $errors "users.embedding.password is empty"                       }}{{- end }}
{{- if not .Values.users.migration.password                  }}{{- $errors = append $errors "users.migration.password is empty"                       }}{{- end }}
{{- if not .Values.users.otel.password                       }}{{- $errors = append $errors "users.otel.password is empty"                            }}{{- end }}
{{- if not .Values.users.keycloak.user.password              }}{{- $errors = append $errors "users.keycloak.user.password is empty"                   }}{{- end }}
{{- if not .Values.users.vectorizationJob.password           }}{{- $errors = append $errors "users.vectorizationJob.password is empty"                }}{{- end }}
{{- if not .Values.users.vectorStore.password                }}{{- $errors = append $errors "users.vectorStore.password is empty"                     }}{{- end }}

{{/* ── application.admin: full policy check ── */}}
{{- $appPw := .Values.users.application.admin.password -}}
{{- if not $appPw }}
  {{- $errors = append $errors "users.application.admin.password is empty" }}
{{- else }}
  {{- if lt (len $appPw) 8                                              }}{{- $errors = append $errors "users.application.admin.password must be at least 8 characters"                              }}{{- end }}
  {{- if not (regexMatch `[A-Z]` $appPw)                               }}{{- $errors = append $errors "users.application.admin.password must contain at least one uppercase letter"                }}{{- end }}
  {{- if not (regexMatch `[a-z]` $appPw)                               }}{{- $errors = append $errors "users.application.admin.password must contain at least one lowercase letter"                }}{{- end }}
  {{- if not (regexMatch `[!@#$%^&*_+|?<>/]` $appPw)                  }}{{- $errors = append $errors "users.application.admin.password must contain at least one special character (!@#$%^&*_+|?<>/)" }}{{- end }}
{{- end }}

{{/* ── keycloak.admin: full policy check ── */}}
{{- $kcPw := .Values.users.keycloak.admin.password -}}
{{- if not $kcPw }}
  {{- $errors = append $errors "users.keycloak.admin.password is empty" }}
{{- else }}
  {{- if lt (len $kcPw) 8                                              }}{{- $errors = append $errors "users.keycloak.admin.password must be at least 8 characters"                              }}{{- end }}
  {{- if not (regexMatch `[A-Z]` $kcPw)                               }}{{- $errors = append $errors "users.keycloak.admin.password must contain at least one uppercase letter"                }}{{- end }}
  {{- if not (regexMatch `[a-z]` $kcPw)                               }}{{- $errors = append $errors "users.keycloak.admin.password must contain at least one lowercase letter"                }}{{- end }}
  {{- if not (regexMatch `[!@#$%^&*_+|?<>/]` $kcPw)                  }}{{- $errors = append $errors "users.keycloak.admin.password must contain at least one special character (!@#$%^&*_+|?<>/)" }}{{- end }}
{{- end }}

{{/* ── Emit all errors at once ── */}}
{{- if $errors }}
  {{- $msg := printf "\n\nPassword validation failed with %d error(s):\n" (len $errors) -}}
  {{- range $i, $e := $errors -}}
    {{- $msg = printf "%s  [%d] %s\n" $msg (add1 $i) $e -}}
  {{- end -}}
  {{- fail $msg -}}
{{- end -}}
{{- end -}}
{{- end -}}
