buildscript {
    repositories {
        maven { url = 'https://files.minecraftforge.net/maven' }
        maven { url = 'https://maven.blamejared.com' }
        jcenter()
        mavenCentral()
    }
    dependencies {
        classpath group: 'net.minecraftforge.gradle', name: 'ForgeGradle', version: '3.+', changing: true
        classpath group: 'com.blamejared', name: 'ModTemplate', version: '1.+', changing: true
    }
}
plugins {
    id "com.matthewprenger.cursegradle" version "1.4.0"
}
apply plugin: 'com.blamejared.modtemplate'
apply plugin: 'net.minecraftforge.gradle'
apply plugin: 'eclipse'
apply plugin: 'maven-publish'


version = "3.1.0"
group = "com.blamejared.slimyboyos"
archivesBaseName = "SlimyBoyos"

sourceCompatibility = targetCompatibility = compileJava.sourceCompatibility = compileJava.targetCompatibility = '1.8' // Need this here so eclipse task generates correctly.

minecraft {
    mappings channel: 'snapshot', version: '20201028-1.16.3'
    //accessTransformer = file('src/main/resources/META-INF/slime_at.cfg')
    runs {
        client {
            workingDirectory project.file('run')

            mods {
                slimyboyos {
                    source sourceSets.main
                }
            }
        }

        server {
            workingDirectory project.file('run')

            mods {
                slimyboyos {
                    source sourceSets.main
                }
            }
        }

        data {
            workingDirectory project.file('run')

            args '--mod', 'slimyboyos', '--all', '--output', file('src/generated/resources/'), '--existing', file('src/main/resources/')

            mods {
                slimyboyos {
                    source sourceSets.main
                }
            }
        }
    }
}

modTemplate {
    mcVersion "1.16.5"
    curseHomepage "https://www.curseforge.com/minecraft/mc-mods/slimyboyos"
    displayName "SlimyBoyos"

    changelog {
        enabled true
        firstCommit "08fe429189558c0f5dec1f21db81ad9076fe58b9"
        repo "https://github.com/jaredlll08/SlimyBoyos"
    }
    versionTracker {
        enabled true
        author "Jared"
    }
    webhook {
        enabled true
        curseId "281993"
        avatarUrl "https://media.forgecdn.net/avatars/130/894/636463564739010146.png"
    }
}

sourceSets.main.resources { srcDir 'src/generated/resources' }

dependencies {
    minecraft 'net.minecraftforge:forge:1.16.5-36.0.0'
}

jar {
    manifest {
        attributes([
                "Specification-Title"     : "slimyboyos",
                "Specification-Vendor"    : "BlameJared",
                "Specification-Version"   : "1",
                "Implementation-Title"    : project.name,
                "Implementation-Version"  : "${version}",
                "Implementation-Vendor"   : "BlameJared",
                "Implementation-Timestamp": new Date().format("yyyy-MM-dd'T'HH:mm:ssZ")
        ])
    }
}


task sourcesJar(type: Jar, dependsOn: classes) {
    description = 'Creates a JAR containing the source code.'
    from sourceSets.main.allSource
    classifier = 'sources'
}

task javadocJar(type: Jar, dependsOn: javadoc) {
    description = 'Creates a JAR containing the JavaDocs.'
    from javadoc.destinationDir
    classifier = 'javadoc'
}

task deobfJar(type: Jar) {
    description = 'Creates a JAR containing the non-obfuscated compiled code.'
    from sourceSets.main.output
    classifier = "deobf"
}
artifacts {
    archives sourcesJar
    archives javadocJar
    archives deobfJar
}

publish.dependsOn(project.tasks.getByName("assemble"))
publish.mustRunAfter(project.tasks.getByName("build"))

publishing {

    publications {

        mavenJava(MavenPublication) {

            groupId project.group
            artifactId project.archivesBaseName
            version project.version
            from components.java

            // Allows the maven pom file to be modified.
            pom.withXml {

                // Go through all the dependencies.
                asNode().dependencies.dependency.each { dep ->

                    println 'Surpressing artifact ' + dep.artifactId.last().value().last() + ' from maven dependencies.'
                    assert dep.parent().remove(dep)
                }
            }

            artifact sourcesJar {

                classifier 'sources'
            }
            artifact javadocJar {

                classifier 'javadoc'
            }
            artifact deobfJar {

                classifier 'deobf'
            }
        }
    }

    repositories {

        maven {

            url "file://" + System.getenv("local_maven")
        }
    }
}

curseforge {

    apiKey = findProperty('curseforge_api_token') ?: 0
    project {
        id = "281993"
        releaseType = 'release'
        changelog = file("changelog.md")
        changelogType = 'markdown'

        addArtifact(deobfJar)
    }
}
