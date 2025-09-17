plugins {
    id 'java'
}

group = '__PACKAGE__'
version = '0.1.0'

repositories { mavenCentral() }

dependencies {
    testImplementation platform('org.junit:junit-bom:5.10.2')
    testImplementation 'org.junit.jupiter:junit-jupiter'
    testRuntimeOnly  'org.junit.platform:junit-platform-launcher'
}

test { useJUnitPlatform() }
