properties:
  configuration:
    activeRevisionsMode: Single
    ingress:
      additionalPortMappings:
      # for some reason - this is not working
      - exposedPort: 631
      # port should be internal
        external: true
        targetPort: 631
      allowInsecure: false
      external: true
      targetPort: 8000
      traffic:
      - latestRevision: true
        weight: 100
      transport: http
  template:
    containers:
    - image: ${image_name}
      name: ipod
      resources:
        cpu: 0.25
        memory: 0.5Gi
      env:
        - name  : MYSQL_DATABASE
          value : ipod_db
        - name  : MYSQL_USER
          value : ipodadmin
        - name  : MYSQL_PASSWORD
          secretRef: mysql-password
        - name: MYSQL_HOST
          value : ${mysql_host}
        - name: MYSQL_SSL_CA
          value : /app/DigiCertGlobalRootCA.crt.pem
        - name: DJANGO_PRODUCTION
          value : True
        - name : SECRET_KEY
          secretRef: secret-key
        - name: ALLOWED_HOSTS
          value : '*'
        - name: MYSQL_PORT
          value : 3306