#!/bin/bash
sleep 5s

# echo "ok"
# PORT=$(kubectl get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

### Istio Ingress Gateway Port 80 - NodePort
PORT=$(kubectl -n istio-system get svc istio-ingressgateway -o json | jq '.spec.ports[] | select(.port == 80)' | jq .nodePort)


echo $PORT
echo $applicationURL:$PORT$applicationURI

if [[ ! -z "$PORT" ]];
then

    response=$(curl -s $applicationURL:$PORT$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)

    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1;
    fi;

    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed"
        else
            echo "HTTP Status code is not 200"
            exit 1;
    fi;

else
        echo "The Service does not have a NodePort"
        exit 1;
fi;