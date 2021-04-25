K3S_IMAGE_NAME=rancher/k3s:v1.19.5-k3s2
K3D_CLUSTER_NAME = kafka-dev-cluster

install-k3d:
	curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.2.0 bash
	k3d --version

delete-cluster:
	k3d cluster delete $(K3D_CLUSTER_NAME) || echo

create-cluster:
	k3d cluster create \
		--wait \
		--image $(K3S_IMAGE_NAME) \
		$(K3D_CLUSTER_NAME)

switch-context:
	kubectl config use-context k3d-$(K3D_CLUSTER_NAME)
	kubectl cluster-info
	docker ps

create-kafka:
	@echo "The total time takes ~2-3 minutes"
	kubectl create --namespace=kafka -f k8s/01_namespace.yml
	kubectl create --namespace=kafka -f k8s/02_strimzi_kafka_operator.yml
	@echo "This next step takes ~60seconds"
	kubectl wait deploy/strimzi-cluster-operator --for=condition=available --timeout=300s -n kafka
	kubectl create --namespace=kafka -f k8s/03_kafka_persistent_single.yml
	@echo "This next step takes ~100seconds"
	kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

produce:
	@echo "This will open a console where you can type messages to send to this topic"
	kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.22.1-kafka-2.7.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic my-topic

consume:
	@echo "This will open a console where you can receive messages published in above target `publish`"
	kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.22.1-kafka-2.7.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

k9s:
	k9s -n kafka