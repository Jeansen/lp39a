# Admission Controller demo

A simple Quarkus Services that utilizes the Kubernetes API, written in Kotlin.

## Requirements

Using this admission controller requires a working Kubernetes cluster >= 1.27 and an image registry, e.g. Harbor. In addition, you will need to have Docker and openssl installed.

## Prepare

After cloning this repository, change into the `src/k8s` folder and execute the `gen_certs.sh`. 

    REGISTRY=<your-registy-url>/<image-group>/lp39a:latest ./gen_certs.sh

This will create all necessary certificates and place them in the `main/jib` folder. It will also create the relevant secrets in your cluster and set the right image path for the admission controller image. So, make sure you can access your cluster via `kubectl`. Everything will be placed in the `default` namespace.

## Build

Please review the `application.properties` and adapt it to your local setup, especially the following settings need your attention:

    quarkus.container-image.group=
    quarkus.container-image.username=
    quarkus.container-image.password=
    quarkus.container-image.registry=

## Apply the manifests

Having the manifests prepared, an image pushed to your registry and necessary secres already installed in the cluster, you are ready to go:

    kubectl apply src/k8s/manifests.yaml

Check your cluster and make sure everything is in order:

    kubectl -n default get deployment lp39a

    # Ouput
    # NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    # lp39a   1/1     1            1           11m

    kubectl get validatingwebhookconfigurations.admissionregistration.k8s.io lp39a
    
    # Ouput
    # NAME    WEBHOOKS   AGE
    # lp39a   1          11m

Finally, ready for ignition! With the following command the validating webhook, which will call the admission controller (lp39a).

    kubectl -n default patch --type=json -p='[{"op": "replace", "path": "/webhooks/0/failurePolicy", "value":"Fail"}]' validatingwebhookconfigurations.admissionregistration.k8s.io/lp39a

## Action!

If you execute the following:

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: canary
    spec:
      containers:
      - image: busybox
        name: canary
    EOF

You should get the following answer:

    Error from server: error when creating "STDIN": admission webhook "lp39a.k8s.lab" denied the request: Try again!

Disabling the validation webhook is as simple as:

    kubectl -n default patch --type=json -p='[{"op": "replace", "path": "/webhooks/0/failurePolicy", "value":"Ignore"}]' validatingwebhookconfigurations.admissionregistration.k8s.io/lp39a

## Kudos

Many thanks to Fernando Ripoll (https://github.com/pipo02mix/grumpy) who's repository provided me a great template as a starting point. Especially the `gen_certs.sh` and additional configuration files, although I ahd to do some amendments and updates. For instance, the validating webhook API already matured to v1 and openssl needed to be adapted to some recent GO changes to make communication more secure.

# Next steps

- Quarkus Native
- (Kotlin Native)

# Fun fact

If you wander why I named the project lp39a, check out https://en.wikipedia.org/wiki/Kennedy_Space_Center_Launch_Complex_39. Every rocket needs a launch complex and a GO! Every admission controller serves as a launch site and if the admission controller gives a GO, a pod is allowed to launch ;-)
