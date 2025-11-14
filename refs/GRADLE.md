Grade

Make sure jdk version in shell is same as project.
Make sure is same as IntelliJ.


```bash
echo $JAVA_HOME                                 
java -version
```


```bash
./gradlew build -i
```

```bash
./gradlew test --tests com.playgami.playerauthx.service.JwkRotationServiceTest
```

See dependencies
```bash
 ./gradlew dependencies --configuration compileClasspath 
 ./gradlew dependencies --configuration runtimeClasspath
 ./gradlew dependencies --configuration testRuntimeClasspath
 ```
