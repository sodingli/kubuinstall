#!/usr/bin/env bash
# Created by deirk93 on 4/12/19

set -e

pushd $(dirname $0) > /dev/null
SCRIPTPATH=$(pwd -P)
popd > /dev/null
SCRITPT=$(basename $0)


REGISTER_IMAGE="registry"
REGISTER_VERSION="latest"
REGISTER_DOMAIN="repo.dashuai.life"
REGISTER_NAME="mageregistry"
EXPOSEDPORT=5000
NGINX_IMAGE="nginx"
NGINX_VERSION="latest"
NGINX_NAME="nginxre"
NGINX_PORT=8080


REGISTRYHOME="/opt/registry"
NGINXHOME="/opt/nginx"

function Deployment(){
    echo  -e "pull the registry image"

    PULLVERSION=$(docker pull "${REGISTER_IMAGE}:${REGISTER_VERSION}")

    PULLRESULT=$(echo ${PULLVERSION} | awk '{print $NF}')
    if [ ${PULLRESULT} == "${REGISTER_IMAGE}:${REGISTER_VERSION}" ];then

        RESULT_TMP=$(mkdir -p  "${REGISTRYHOME}/config")

        if [ $$ != "" ];then

            cd  "${REGISTRYHOME}/config"

            cat >> config.yml <<EOF
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    #you'd better to change the path to the Net store,like GlustFS and Ceph.
    rootdirectory: ${REGISTRYHOME}/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
EOF
            mkdir -p "${REGISTRYHOME}/register"
            if [ $$ != "" ];then
                echo -e "docker registry install successed.."
            fi
        else
           echo -e "${REGISTRYHOME}:config   not exit..."
           exit
        fi
    else
        echo -e "docker pull ${REGISTER_IMAGE}:${REGISTER_VERSION} failed ..."
        exit

    fi
}



function DeployNginx(){
    echo -e "docker pull ${NGINX_IMAGE}:${NGINX_VERSION}"
    PULLNGINXVERSION=$(docker pull "${NGINX_IMAGE}:${NGINX_VERSION}")

    PULLNGINXRESULT=$(echo ${PULLNGINXVERSION} | awk '{print $NF}')
    if [ ${PULLNGINXRESULT} == "${NGINX_IMAGE}:${NGINX_VERSION}" ];then
        
        for i in log config;
        do
           mkdir -p  "${NGINXHOME}/${i}"
        done
    
    fi
    
    REGISTER_IP=$(docker ps -a -f name="${REGISTER_NAME}" -f status=running  | grep "${REGISTER_NAME}" |xargs docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' )
    if [ $REGISTER_IP = "" ];then
       echo -e "Get registry IP failed.."
       exit
    fi

    cd ${NGINXHOME}/config
    cat >> nginx.conf << EOF

user nginx;
worker_processes auto;
error_log ${NGINXHOME}/error.log;
pid /tmp/nginx.pid;


events {
    worker_connections 1024;
}


http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';


    access_log  ${NGINXHOME}/access.log  main;


    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;


    include             ${NGINXHOME}/mime.types;
    default_type        application/octet-stream;


    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    #include /etc/nginx/conf.d/*.conf;


    server {
        listen       ${NGINX_PORT} default_server;
        listen       [::]:${NGINX_PORT} default_server;
        server_name  {REGISTER_DOMAIN};
        #root         /usr/share/nginx/html;


        # Load configuration files for the default server block.
        #include /etc/nginx/default.d/*.conf;


        location / {
         }
        
        location /v2/ {
        # Do not allow connections from docker 1.5 and earlier
        # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
        if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
         return 404;
         }
        proxy_pass http://docker-registry;
        proxy_set_header Host $http_host; # required for docker client's sake
        proxy_set_header X-Real-IP $remote_addr; # pass on real client's IP
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 900;

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
    #include ./registry/registry.conf;

server {
        listen 443;
        server_name ${REGISTER_DOMAIN};
         # disable any limits to avoid HTTP 413 for large image uploads
         client_max_body_size 0;

         # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
         chunked_transfer_encoding on;
         location /v2/ {
         # Do not allow connections from docker 1.5 and earlier
         # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
         if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
         return 404;
         }
         proxy_pass http://docker-registry;
         proxy_set_header Host $http_host; # required for docker client's sake
         proxy_set_header X-Real-IP $remote_addr; # pass on real client's IP
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header X-Forwarded-Proto $scheme;
         proxy_read_timeout 900;
}
upstream docker-registry {
          server ${REGISTER_IP}:5000;
         }

 }
}

EOF

    cd  ${NGINXHOME}
    cat >> mime.types <<EOF
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    application/javascript                           js;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt;
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;

    image/png                                        png;
    image/svg+xml                                    svg svgz;
    image/tiff                                       tif tiff;
    image/vnd.wap.wbmp                               wbmp;
    image/webp                                       webp;
    image/x-icon                                     ico;
    image/x-jng                                      jng;
    image/x-ms-bmp                                   bmp;

    font/woff                                        woff;
    font/woff2                                       woff2;

    application/java-archive                         jar war ear;
    application/json                                 json;
    application/mac-binhex40                         hqx;
    application/msword                               doc;
    application/pdf                                  pdf;
    application/postscript                           ps eps ai;
    application/rtf                                  rtf;
    application/vnd.apple.mpegurl                    m3u8;
    application/vnd.google-earth.kml+xml             kml;
    application/vnd.google-earth.kmz                 kmz;
    application/vnd.ms-excel                         xls;
    application/vnd.ms-fontobject                    eot;
    application/vnd.ms-powerpoint                    ppt;
    application/vnd.oasis.opendocument.graphics      odg;
    application/vnd.oasis.opendocument.presentation  odp;
    application/vnd.oasis.opendocument.spreadsheet   ods;
    application/vnd.oasis.opendocument.text          odt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation
                                                     pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                                     xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                     docx;
    application/vnd.wap.wmlc                         wmlc;
    application/x-7z-compressed                      7z;
    application/x-cocoa                              cco;
    application/x-java-archive-diff                  jardiff;
    application/x-java-jnlp-file                     jnlp;
    application/x-makeself                           run;
    application/x-perl                               pl pm;
    application/x-pilot                              prc pdb;
    application/x-rar-compressed                     rar;
    application/x-redhat-package-manager             rpm;
    application/x-sea                                sea;
    application/x-shockwave-flash                    swf;
    application/x-stuffit                            sit;
    application/x-tcl                                tcl tk;
    application/x-x509-ca-cert                       der pem crt;
    application/x-xpinstall                          xpi;
    application/xhtml+xml                            xhtml;
    application/xspf+xml                             xspf;
    application/zip                                  zip;

    application/octet-stream                         bin exe dll;
    application/octet-stream                         deb;
    application/octet-stream                         dmg;
    application/octet-stream                         iso img;
    application/octet-stream                         msi msp msm;

    audio/midi                                       mid midi kar;
    audio/mpeg                                       mp3;
    audio/ogg                                        ogg;
    audio/x-m4a                                      m4a;
    audio/x-realaudio                                ra;

    video/3gpp                                       3gpp 3gp;
    video/mp2t                                       ts;
    video/mp4                                        mp4;
    video/mpeg                                       mpeg mpg;
    video/quicktime                                  mov;
    video/webm                                       webm;
    video/x-flv                                      flv;
    video/x-m4v                                      m4v;
    video/x-mng                                      mng;
    video/x-ms-asf                                   asx asf;
    video/x-ms-wmv                                   wmv;
    video/x-msvideo                                  avi;
}
EOF

    echo -e "start nginx ..."
    docker run -d -p ${NGINX_PORT} -v "${NGINXHOME}/config/nginx.conf":/etc/nginx/nginx.conf \
    -v $NGINXHOME/log:/var/log/nginx \
    --name=$NGINX_NAME \
    "${NGINX_IMAGE}:${NGINX_VERSION}"

}




function RunRegistry(){
    echo -e "start registory..."
    docker run -d -p ${EXPOSEDPORT}:5000 \
    --name="${REGISTER_NAME}" --restart=always \
    -v "${REGISTRYHOME}/config/config.yml":/etc/docker/registry/config.yml \
    -e REGISTRY_STORAGE_DELETE_ENABLED=true \
    -v "${REGISTRYHOME}/register":/var/lib/registry \
    ${REGISTER_IMAGE}:${REGISTER_VERSION}

}


function GetStatus(){
    Getstatus=$(docker ps -a -f name="${REGISTER_NAME}" -f status=running  | grep "${REGISTER_NAME}")
    if [ "${Getstatus}" != "" ];then
        echo "Registry is running..."
	    echo ""
        echo $Getstatus "\n"
        exit
    else
        echo "Registry start failed...Please used command 'docker logs ${REGISTER_NAME}' to debug  or kill the abnormal instance."
        PS3="Enter you choice: "
        _INPUT='^[0-9]$+'
        select opt in "remove" "debug";do
            case ${opt} in
                remove)
                 KillFailedContained=$(docker rm -f ${REGISTER_NAME})
                 Deployment
                  ;;
                debug)
                 echo "Please use 'docker logs ${REGISTER_NAME}' to debug"
                 exit
                  ;;
                3)
                  echo "Input error.."
                  ;;
            esac
        done
    fi

}



function ShowUsage(){
    echo "usage:"
    echo -e "-h : Show this message"
    echo -e "-d : Install registry service  on localhost "
    echo -e "-r : Run registry service on localhost "
    echo -e "-s : Check to see if the registry service is installed  locally. "
    echo ""
}


if [ "${1}" == "" ];then
   ShowUsage
fi

while [ "${1}" != ""  ];do

    case ${1} in
    -h| --help)
      ShowUsage

       ;;

    -d | --deploy)
       Deployment
       RunRegistry
       ;;
    -r | --run)
       GetStatus
       RunRegistry
       ;;
    -s | --status )
       GetStatus
       ;;
    *) #匹配静默错误
      echo "Option  requires an argument." >&2
      exit 0
      ;;

    esac
    shift

done
