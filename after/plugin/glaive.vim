call glaive#Install()

Glaive codefmt google_java_executable=`expand('java -jar $HOME/code/libs/java/google-java-format-1.22.0-all-deps.jar')`
Glaive codefmt plugin[mappings]

autocmd FileType javascript,typescript,html,css let b:codefmt_formatter = 'prettier'


