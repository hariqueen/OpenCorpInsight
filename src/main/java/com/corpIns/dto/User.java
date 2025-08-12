package com.corpIns.dto;

public class User {
    private String email;
    private String passwordHash;
    // Getter / Setter
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPasswordHash() {
        return passwordHash;
    }
    public void setPasswordHash(String password_hash) {
        this.passwordHash = passwordHash;
    }
}