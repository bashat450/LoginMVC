using System;
using System.Security.Cryptography;
using System.Text;

public static class PasswordHelper
{
    // Hash password using SHA256
    public static string HashPassword(string password)
    {
        using (SHA256 sha = SHA256.Create())
        {
            byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
    }

    // Verify a plain password against a hashed password
    public static bool VerifyPassword(string enteredPassword, string storedHash)
    {
        string enteredHash = HashPassword(enteredPassword);
        return enteredHash == storedHash;
    }
}
