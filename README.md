# ctm-privacy-guard
Control-M Privacy Guard Integration

# Scripts

These scripts provide a complete toolkit for managing GPG keys and GPG-encrypted files across Control-M agents and servers.
Each script follows a common structure, including usage help (--help), colorful output, logging, and optional parameters.

📢 [Notice](/NOTICE.md)

## 🛠 Available Scripts

| Script | Purpose | 
| ------ | ------- |
| [generate.key.sh](/src/gpg/dsse.gpg.generate.key.sh) | Generate a new GPG private/public key pair | 
| [export.key.sh](/src/gpg/export.key.sh) | Export an existing GPG key to files (public/private) | 
| [import.key.sh](/src/gpg/dsse.gpg.import.key.sh) | Import a GPG key pair from a JSON template | 
| [import.public.key.sh](/src/gpg/dsse.gpg.import.public.key.sh)| Import a GPG public key only | 
| [import.private.key.sh](/src/gpg/dsse.gpg.import.private.key.sh) | Import a GPG private key only | 
| [fingerprint.file.sh](/src/gpg/fingerprint.file.sh) | Calculate fingerprint of a GPG encrypted file | 
| [encrypt.file.sh](/src/gpg/encrypt.file.sh) | Encrypt a file for a given GPG recipient | 
| [delete.key.sh](/src/gpg/dsse.gpg.delete.key.sh)| Delete GPG keys | 
| [delete.template.sh](/src/gpg/dsse.gpg.delete.template.sh) | Delete GPG key files from templates | 
| [deploy.template.sh](/src/gpg/dsse.gpg.deploy.template.sh) | Deploy a GPG key/template onto Control-M agents | 

## 🖥 Common Parameters

| Option | Description |
| ------ | ------- |
| --file | File input or output path (example: a JSON, GPG file, or key file) |
| --directory | Working directory for file operations |
| --name | GPG key name (user name) |
| --email | GPG email address |
| --passphrase | Passphrase to protect or unlock a GPG key |
| --recipient | GPG recipient email or user for encryption |
| --node | (Optional) Target Control-M Node |
| --environment | (Optional) Control-M environment name |
| --help | Show the script's usage examples and exit |

## 🛡 Security and Logging

Logs are saved into:

./proclog/zzm/gpg.log (or /tmp/data/zzm/gpg.log if no write access)

Each script prints system and environment details for traceability.

Scripts verify working directories and will create them if necessary.


## ⚙ Notes

Pre-requisites: You must have gpg, awk, hostname, and bash installed.

Cross-platform: Supports Linux and macOS.

Control-M integration: Scripts optionally retrieve environment settings (like node, agent names) if connected to Control-M.

Modular: Scripts can be run independently or chained together in automation flows.

## GPG Commands Used by Scripts

| Script | GPG Commands and Flow | 
| ------ | ------- |
| generate.key.sh | Create key batch file  | 
| | Execute gpg --batch --generate-key batch_file to create keys | 
| export.key.sh | gpg --export --armor <key> to export public key   | 
| | gpg --export-secret-keys --armor <key> to export private key | 
| import.key.sh | gpg --import public.key | 
| | gpg --import private.key (both from JSON definition) | 
| import.public.key.sh | gpg --import public.key | 
| import.private.key.sh | gpg --import private.key | 
| fingerprint.file.sh | gpg --list-packets file.gpg to extract packet and fingerprint information | 
| encrypt.file.sh | Encrypt with gpg --output output.gpg --encrypt --recipient <user> file  (optional passphrase if specified) | 
| delete.key.sh | gpg --batch --yes --delete-secret-and-public-key <fingerprint> | 
| delete.template.sh | Delete PGP Template for Control-M Agent(s) | 
| deploy.template.sh | Deploy PGP Template for Control-M Agent(s)  | 


# Workflows

The onboarding workflow for MFT Enterprise makes use of these scripts. They are embedded as OS job-type.

- [MFTE External User Onboarding](/src/ctm/onboarding.json)


# Overview

Gnu Privacy Guard (GPG) is a free and open-source encryption tool designed to ensure the confidentiality, integrity, and authenticity of digital data. 

Its purpose is to provide secure communication and data protection by allowing users to encrypt sensitive information with their private keys and decrypt it with recipients' public keys. 

GPG is widely used for email encryption, digital signatures, and secure file sharing, helping individuals and organizations safeguard their privacy, verify the authenticity of messages, and protect against unauthorized access or tampering of data, ensuring secure and trusted communication in an increasingly interconnected digital world.

GPG (Gnu Privacy Guard) Valuable Benefits

Using Privacy Guard (Gnu Privacy Guard or GPG) in connection with managed file transfer (MFT) can offer several valuable benefits, driven by the need for secure and confidential data exchange:

- **Data Confidentiality**: GPG encryption ensures that data transferred via MFT remains confidential. Even if intercepted during transit or stored on remote servers, the encrypted data remains unreadable without the decryption key.

- **Data Integrity**: GPG provides digital signatures that verify the authenticity and integrity of transferred files. This guards against tampering or corruption during transmission.

- **Authentication**: GPG's public key infrastructure (PKI) enables users to verify the identity of the sender. This is crucial in MFT, where trust and authenticity are paramount.

- **Compliance**: Many industries and regulatory frameworks (e.g., HIPAA, GDPR) require secure data exchange and compliance with data protection standards. GPG helps meet these compliance requirements.

- **Non-Repudiation**: GPG's digital signatures provide proof that a file was sent by a specific sender, helping in legal disputes where non-repudiation is necessary.

- **Secure Key Management**: GPG's key management features allow organizations to securely generate, store, and distribute encryption keys, ensuring the confidentiality of data at rest and in transit.

- **Cross-Platform Compatibility**: GPG is available on various operating systems and supports multiple file formats, making it versatile for cross-platform MFT solutions.

- **Cost-Effective**: GPG is open-source and free to use, reducing the cost of implementing secure file transfer solutions.

- **Scalability**: GPG can scale to accommodate the needs of small to large organizations and adapt to growing MFT requirements.

- **Interoperability**: GPG is widely adopted and can integrate with existing MFT systems and protocols, ensuring seamless data exchange with partners and clients.

- **Reduced Risk**: By encrypting sensitive data and ensuring data integrity, GPG reduces the risk of data breaches, leaks, and unauthorized access during file transfers.

- **Secure Automation**: MFT often involves automated processes. GPG can be seamlessly integrated into automated workflows to ensure that data remains secure during automated transfers.

In summary, the value drivers for using Privacy Guard (GPG) in connection with managed file transfer include data confidentiality, integrity, authentication, compliance, non-repudiation, and cost-effectiveness. GPG provides a robust security layer that enhances the reliability and trustworthiness of file transfers, making it a valuable tool for organizations dealing with sensitive data exchanges.



## GPG Basics

There are two types of encryption algorithms: symmetric (also called shared key algorithm) and asymmetric (also known as public key algorithm).


### Process

#### Asymmetric Process

Asymmetric encryption uses two separate keys: a public key and a private key. 
Often a public key is used to encrypt the data while a private key is required to decrypt the data. 
The private key is only given to users with authorized access. As a result, asymmetric encryption can be more effective, but it is also more costly.

![Asymmetric encryption](/images/pgp.asym.png)

#### Symmetric Process 

Symmetric encryption uses the same key for encryption and decryption. 
Because it uses the same key, symmetric encryption can be more cost effective for the security it provides. 
That said, it is important to invest more in securely storing data when using symmetric encryption.

![Symmetric encryption](/images/pgp.sym.png)


### Building Block
The building blocks of GPG (Gnu Privacy Guard) are the fundamental components and concepts that make up the encryption and cryptographic system.


#### Building Blocks List

- **Key Pair**: GPG relies on a pair of cryptographic keys: a public key and a private key. The public key is used for encryption and verifying signatures, while the private key is used for decryption and creating signatures.

- **Public Key**: This is the key that you share with others. It's used by others to encrypt data that only you can decrypt with your private key. It's also used to verify signatures created with your private key.

- **Private Key**: This key is kept secret and securely stored. It's used for decrypting messages encrypted with your public key and for creating digital signatures.

- **Passphrase**: A passphrase is a strong password that protects your private key. It's required to unlock your private key for decryption and signing operations.

- **Keyring**: GPG uses keyrings to manage keys. A keyring is a collection of public and private keys, organized in keyrings files. Common keyrings include "pubring.kbx" (public keys) and "secring.gpg" (secret keys).

- **Key ID**: Each keypair has a unique Key ID (Key Identifier) that can be used to refer to a specific key. Key IDs are used when importing, exporting, or referencing keys.

- **Key Fingerprint**: A fingerprint is a cryptographic hash of a key's public key data. It's a way to uniquely identify a key and verify its integrity.

- **Encryption**: GPG uses strong encryption algorithms to secure data. It encrypts data with the recipient's public key, ensuring that only the recipient with the corresponding private key can decrypt it.

- **Decryption**: The process of decrypting data using the recipient's private key to reveal the original message.

- **Digital Signatures**: GPG allows users to create digital signatures to verify the authenticity and integrity of messages or files. Signatures are created using the sender's private key and verified using the sender's public key.

- **Trust Model**: GPG uses a trust model to determine the level of trust you have in other users' keys. Users can sign each other's keys to indicate trust. Trust levels include "unknown", "none", "marginal", "full" and "ultimate".

- **Keyserver**: A keyserver is a network service that allows users to upload and download public keys. Users can search for keys and exchange keys with others through key servers.

- **Revocation Certificate**: A revocation certificate is a file generated by the key owner to revoke a compromised or lost key. It's used to inform others that the key is no longer valid.



These building blocks form the foundation of GPG's encryption, decryption, and digital signature capabilities, enabling secure communication, data protection, and digital identity verification. Understanding these components is crucial for effectively using GPG for privacy and security.

### Format

#### Structured Format

The key structure is organized in a specific format that adheres to the OpenPGP standard. 
GPG keys are typically stored in files with extensions like .asc or .gpg, and they can be exported and imported for use in various GPG operations, such as encryption, decryption, and digital signatures. 
Understanding the structure of a GPG key is essential for managing and working with keys securely.


#### Header Section:

- **Public Key Header:** Contains information about the type of key and its usage.
- **Version:** Specifies the version of the GPG key format.
- **Creation Time:** The timestamp when the key was generated.
- **Algorithm:** The cryptographic algorithm used for the key.
- **Key ID:** A unique identifier for the key.
- **Fingerprint:** A cryptographic hash of the key data for verification.
- **User IDs:** Information about the key's owner, including name, email address, and comment (if any).
- **Subkeys:** If applicable, information about subkeys (additional keys associated with the primary key).
- **Public Key Data:** The actual public key data that can be used by others to encrypt messages or verify signatures.
- **User IDs:** Each user ID contains the name and email address of the key's owner, along with optional comments.
- **Signature Packets:** Digital signatures created by the key owner or others to certify the authenticity and integrity of the key and user IDs.
- **Subkey Packets:** If the key has subkeys, each subkey is represented as a subkey packet, including its own public key data.
- **Revocation Certificates:** If the key owner has generated revocation certificates, they can be included in the key to indicate the key's revocation status.
</details>     
        
#### ASCII Armor

ASCII armor (or ASCII armor) is a way to represent binary data, such as cryptographic keys, digital signatures, or encrypted messages, using plain text characters from the ASCII character set. It serves two main purposes:

- **Human-Readable Representation**: ASCII armor makes it possible to represent binary data in a human-readable format. This is essential for sharing cryptographic data through text-based communication channels, such as email or printed documents, where binary data might be corrupted or misinterpreted.
- **Data Integrity**: By converting binary data into ASCII text, ASCII armor helps ensure that the data remains intact and unaltered during transmission or storage. The text-based representation is less susceptible to corruption.

ASCII armor typically involves encoding binary data into a set of printable ASCII characters, often using Base64 encoding or other similar techniques. When you encounter cryptographic keys or messages in ASCII armor format, they are designed to be easily copied and pasted, shared in emails, or stored in text files without any loss of data or integrity.

GPG (Gnu Privacy Guard) commonly uses ASCII armor to represent public keys, digital signatures, and encrypted messages, allowing users to exchange secure information through text-based communication channels while maintaining data integrity and human readability.  

### GPG Keyring System

### Central Keyring

Using a separate keyring in GPG to encrypt a file involves creating or utilizing an alternative keyring file instead of the default one. This can be useful for specific projects or to maintain separate sets of keys for different contexts. Here's how to do it:

#### Create a Separate Keyring

1. You need to create a new, separate keyring. You can do this by initializing a new keyring with a key generation command and specifying the keyring file. Let's create a new directory for our separate keyring and generate a new key pair in it.

mkdir ~/my_separate_keyring


2. Import Public Keys into the Separate Keyring. If you want to encrypt files for someone else using the separate keyring, you'll need to import their public key into it.

3. Encrypt a File Using the Separate Keyring. Now, to encrypt a file using a key from the separate keyring, specify the --homedir option again to use the alternative keyring for the encryption operation.



#### Encrypt & Decrypt

gpg --homedir ~/my_separate_keyring --recipient recipient@email.com --encrypt file_to_encrypt

gpg --homedir ~/my_separate_keyring --decrypt encrypted_file.gpg > decrypted_file
 

Using a separate keyring can help organize keys and maintain different sets of keys for various purposes, enhancing your operational security and flexibility in managing encrypted communications or files.


## YouTube

![Encryption with Control-M Managed File Transfer](https://youtu.be/U4gu-sdqNek)


![How to use PGP with Control-M for Advanced File Transfer](https://youtu.be/D8hhMSz8z7g)


![PGP mit Control-M for File Transfer](https://youtu.be/PS6ew1S1f88)

