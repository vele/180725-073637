IMAGE_NAME = mhristov/internal-service
TAG = latest
KIND_CLUSTER = internal-services

# -------------------
# Docker
# -------------------
docker-build:
	docker build -t $(IMAGE_NAME):$(TAG) .

docker-push: docker-build
	docker push $(IMAGE_NAME):$(TAG)

# -------------------
# Helm
# -------------------
deploy-dev:
	helm upgrade --install internal-service ./internal-service \
		--set prod=false \
		--set image.hub=docker.io \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(TAG)

deploy-prod:
	helm upgrade --install internal-service-prod ./internal-service \
		--set prod=true \
		--set image.hub=docker.io \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(TAG)

# -------------------
# GitOps (Kustomize)
# -------------------
render:
	helm template internal-service ./internal-service > gitops/base/internal-service.yaml

apply-dev: render
	kubectl apply -k gitops/overlays/dev

apply-prod: render
	kubectl apply -k gitops/overlays/prod

# -------------------
# Cleanup
# -------------------
clean:
	helm uninstall internal-service || true
	helm uninstall internal-service-prod || true
	kubectl delete all -l app=internal-service || true

reset-cluster:
	kind delete cluster --name $(KIND_CLUSTER) || true
	kind create cluster --name $(KIND_CLUSTER)
