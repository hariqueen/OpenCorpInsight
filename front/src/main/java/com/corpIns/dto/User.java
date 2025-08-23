package com.corpIns.dto;

public class User {
    private int userSno;
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
    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    
    public int getUserSno() {
        return userSno;
    }
    public void setUserSno(int userSno) {
        this.userSno = userSno;
    }
}
