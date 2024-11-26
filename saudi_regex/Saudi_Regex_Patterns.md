
# Common Regex Patterns for Saudi Arabia Applications

## 1. Saudi Mobile Numbers
Saudi mobile numbers typically start with `05` and have 10 digits.

**Regex**:  
```regex
^05[0-9]{8}$
```

**Example Valid Numbers**:  
`0501234567`, `0559876543`

---

## 2. National ID Numbers
Saudi National ID numbers are exactly 10 digits and often start with `1` for citizens or `2` for residents.

**Regex**:  
```regex
^(1|2)\d{9}$
```

**Example Valid IDs**:  
`1001234567`, `2009876543`

---

## 3. Iqama Numbers (Residence Permit)
Iqama numbers are 10 digits long, similar to National IDs, but only used by residents.

**Regex**:  
```regex
^2\d{9}$
```

**Example Valid Numbers**:  
`2001234567`

---

## 4. Postal Codes (ZIP Codes)
Saudi postal codes are 5 digits long.

**Regex**:  
```regex
^\d{5}$
```

**Example Valid Codes**:  
`12345`, `54321`

---

## 5. CR Number (Commercial Registration)
The Commercial Registration (CR) number for businesses is often a 10-digit number.

**Regex**:  
```regex
^\d{10}$
```

**Example Valid Numbers**:  
`1234567890`

---

## 6. Vehicle Plate Numbers
Vehicle plates in Saudi Arabia often have a combination of Arabic letters and numbers.

**Regex (General)**:  
```regex
^[0-9]{1,4}[- ]?[ء-ي]{1,3}$
```

**Example Valid Plates**:  
`123 أ ب ج`, `12-ك ل م`

---

## 7. Bank Account Numbers (IBAN)
Saudi IBANs start with `SA` followed by 22 alphanumeric characters.

**Regex**:  
```regex
^SA\d{2}[A-Z0-9]{22}$
```

**Example Valid IBANs**:  
`SA0320000000608010167519`

---

## 8. Email Addresses
Email validation for apps in Saudi Arabia follows global standards.

**Regex**:  
```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

**Example Valid Emails**:  
`example@domain.com`, `user123@gmail.com`

---

## 9. Names in Arabic
Arabic names may consist of Arabic letters and spaces, optionally allowing a few special characters like hyphens.

**Regex**:  
```regex
^[ء-ي\s\-]+$
```

**Example Valid Names**:  
`محمد خالد`, `عبدالله-التركي`

---

## 10. Dates in Saudi Format (Gregorian)
Dates are often in the `DD/MM/YYYY` format.

**Regex**:  
```regex
^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$
```

**Example Valid Dates**:  
`18/11/2024`, `01/01/2023`

---

## 11. Hijri Dates
Hijri calendar dates can have a similar format but with a different range of years and months.

**Regex**:  
```regex
^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(14[0-9]{2})$
```

**Example Valid Dates**:  
`12/08/1445`

---

## 12. Credit Card Numbers
For payment integration, Saudi apps might validate global credit card numbers.

**Regex**:  
```regex
^4[0-9]{12}(?:[0-9]{3})?$  # Visa
^5[1-5][0-9]{14}$          # MasterCard
```

---

## 13. Password Validation
Strong password requirements for Saudi apps often include uppercase, lowercase, digits, and special characters.

**Regex**:  
```regex
^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$
```

**Example Valid Passwords**:  
`Password1!`, `Strong@123`

---

## 14. Saudi Driving License Number
Driving license numbers are typically numeric and fixed-length (e.g., 8 digits).

**Regex**:  
```regex
^\d{8}$
```

**Example Valid Numbers**:  
`12345678`

---

## 15. Custom Arabic/English Text (No Numbers or Special Characters)
For fields that accept text only (in Arabic or English):

**Regex**:  
```regex
^[a-zA-Zء-ي\s]+$
```

---

These regex patterns can be tailored based on the specific requirements of the application. Let me know if you need further customization or additional patterns!
