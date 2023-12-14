# Automated Accessbility testing

To use pa11y or axe-cli for accessibility testing in your bash or PowerShell scripts, you'll first need to ensure Node.js is installed on your system, as both tools are Node.js packages. Here's how you can set up and use these tools:

## **Using pa11y**

Open your terminal or PowerShell and run the following command to install pa11y globally:

```
npm install -g pa11y
```

Create a bash or PowerShell script that runs pa11y against a specified URL. Here's an example for a bash script:

```
URL="https://example.com" # Replace with your URL
pa11y $URL
```

**Run the Script:**
Make the bash script executable with chmod +x scriptname.sh and then run it. For PowerShell, just execute the script.

## **Using axe-cli**

Install axe-cli globally using npm:

```
npm install -g axe-cli
```

Create a Bash/Powershell Script:
Similar to pa11y, create a script for axe-cli. Here's a bash script example:

```
URL="https://example.com" # Replace with your URL
axe $URL
```

And for PowerShell:

```
$URL = "https://example.com" # Replace with your URL
axe $URL
```

Run the script as you would with the pa11y script.
