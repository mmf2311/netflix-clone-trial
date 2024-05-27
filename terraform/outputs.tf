output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.netflix_clone.repository_url
}

output "kubeconfig" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
