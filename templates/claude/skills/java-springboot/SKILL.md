---
name: java-springboot
description: >-
  Java and Spring Boot development patterns — project scaffolding, JPA entities,
  REST endpoints with DTOs, N+1 query fixes, Docker builds, and dependency
  vulnerability scanning. Use this skill whenever the user is working on a
  Spring Boot or Java project: creating entities, building REST APIs, fixing
  JPA performance issues, writing Spring Boot tests, Dockerizing Spring Boot
  apps, or checking for dependency vulnerabilities. Also trigger on phrases
  like "create a Spring Boot project", "add a JPA entity", "build a REST
  endpoint in Java", "fix N+1 queries", "scaffold a Spring service", or any
  task where Spring Boot conventions (Controller → Service → Repository)
  should be followed.
---

# Java & Spring Boot Development Skills

This skill covers patterns for Spring Boot production services. Each section is self-contained — use the one matching the current task. The patterns follow the layered architecture (Controller → Service → Repository) that Spring Boot encourages, with DTOs at API boundaries to decouple internal domain objects from external contracts.

## Skill: Create Spring Boot Project

Use `spring init` (Spring CLI) or start.spring.io to scaffold:

```bash
# Using Spring CLI
spring init --dependencies=web,data-jpa,postgresql,validation,actuator,lombok \
            --java-version=21 --group=com.example --artifact=demo \
            --name=demo --packaging=jar demo.zip
```

Or use Maven archetype:
```bash
mvn archetype:generate \
  -DgroupId=com.example -DartifactId=demo \
  -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.5
```

## Skill: Add JPA Entity

1. Create entity in `src/main/java/com/example/<package>/model/`:
```java
@Entity
@Table(name = "entity_name")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EntityName {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
```

2. Create repository interface:
```java
@Repository
public interface EntityNameRepository extends JpaRepository<EntityName, Long> {
    Optional<EntityName> findByName(String name);
    List<EntityName> findByCreatedAtAfter(LocalDateTime date);
}
```

3. If needed, create migration:
```
src/main/resources/db/migration/V1__create_entity_name.sql
```

## Skill: Add REST Endpoint

1. Create DTO:
```java
public record EntityNameDto(Long id, String name, LocalDateTime createdAt) {
    public static EntityNameDto from(EntityName entity) {
        return new EntityNameDto(entity.getId(), entity.getName(), entity.getCreatedAt());
    }
}
```

2. Create request DTO:
```java
public record CreateEntityNameRequest(@NotBlank @Size(max = 100) String name) {}
```

3. Add controller method to existing or new `@RestController`:
```java
@PostMapping
public ResponseEntity<EntityNameDto> create(@Valid @RequestBody CreateEntityNameRequest req) {
    var entity = service.create(req);
    return ResponseEntity.status(HttpStatus.CREATED).body(EntityNameDto.from(entity));
}
```

4. Service method:
```java
@Transactional
public EntityName create(CreateEntityNameRequest req) {
    var entity = EntityName.builder().name(req.name()).build();
    return repository.save(entity);
}
```

5. Test:
```java
@Test
void create_validRequest_returnsCreated() throws Exception {
    mockMvc.perform(post("/api/v1/entities")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"name\":\"test\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("test"));
}
```

## Skill: Fix N+1 Query Problem

1. Enable SQL logging: `spring.jpa.show-sql=true` in `application.yml`
2. Reproduce and identify repeated SELECT statements in logs
3. Fix with `@EntityGraph`:
```java
@EntityGraph(attributePaths = {"relatedEntity"})
Optional<Entity> findById(Long id);
```
4. Or JOIN FETCH in `@Query`:
```java
@Query("SELECT e FROM Entity e JOIN FETCH e.relatedEntity WHERE e.id = :id")
Optional<Entity> findByIdWithRelated(@Param("id") Long id);
```
5. Verify fix by checking SQL log output — only one query should appear

## Skill: Spring Boot Docker Build

```dockerfile
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
COPY --from=build /app/target/*.jar app.jar
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/actuator/health || exit 1
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## Skill: Dependency Vulnerability Check

```bash
# OWASP Dependency Check (Maven)
mvn org.owasp:dependency-check-maven:check

# Or use Snyk
snyk test
snyk monitor
```
