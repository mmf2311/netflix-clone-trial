output "ecr_repository_url" {
  value = aws_ecr_repository.netflix_clone.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.netflix_clone_cluster.name
}

output "kubeconfig" {
  value = "https://${aws_eks_cluster.eks_cluster.endpoint}"
}
