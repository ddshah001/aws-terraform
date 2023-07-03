resource "random_string" "auth-key" {
  length           = 30
}
resource "random_string" "secure-auth-key" {
  length           = 30
}
resource "random_string" "logged-in-key" {
  length           = 30
}
resource "random_string" "nonce-key" {
  length           = 30
}
resource "random_string" "auth-salt" {
  length           = 30
}
resource "random_string" "secure-auth-salt" {
  length           = 30
}
resource "random_string" "logged-in-salt" {
  length           = 30
}
resource "random_string" "nonce-salt" {
  length           = 30
}