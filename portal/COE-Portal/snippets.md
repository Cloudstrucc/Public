# Content Snippets Configuration for Power Platform CoE Portal

The following content snippets need to be configured in your Power Pages portal for dynamic content management:

## Statistics Section (Anonymous Users)
| Snippet Name | Default Value | Description |
|--------------|---------------|-------------|
| `Active Apps Count` | 250+ | Number of active applications in the platform |
| `Citizen Developers Count` | 75+ | Number of active citizen developers |
| `Environments Count` | 12 | Number of managed environments |
| `Automated Processes` | 180+ | Number of automated processes/flows |

## Key Benefits List
| Snippet Name | Default Value | Description |
|--------------|---------------|-------------|
| `Benefit 1` | Streamlined environment provisioning with proper governance | First key benefit |
| `Benefit 2` | Data Loss Prevention policy management and impact analysis | Second key benefit |
| `Benefit 3` | Centralized app catalog for discovery and reuse | Third key benefit |
| `Benefit 4` | Compliance monitoring and developer guidance | Fourth key benefit |
| `Benefit 5` | Training resources and community support | Fifth key benefit |

## Implementation Instructions

### Creating Content Snippets in Power Pages:

1. **Navigate to Content Management**: 
   - Go to your Power Pages management portal
   - Select "Content" > "Content Snippets"

2. **Create Each Snippet**:
   - Click "New Content Snippet"
   - Enter the snippet name exactly as specified above
   - Set the snippet type to "Text"
   - Enter the default value
   - Set language to appropriate locale (English/French)

3. **Multilingual Configuration**:
   - Create French versions of text snippets for bilingual support
   - Use the same snippet names with French values

### Usage in Liquid Templates:
```liquid
{{ snippets["Active Apps Count"] | default: "250+" }}
{{ snippets["Benefit 1"] | default: "Default benefit text" }}
```

### Dynamic Updates:
- These snippets can be updated through the Power Pages management interface
- Changes take effect immediately without code deployment
- Consider connecting to Dataverse for real-time statistics if needed

### Best Practices:
- Use meaningful default values in case snippets are not configured
- Keep snippet names consistent and descriptive
- Document any dependencies between snippets and page functionality
- Regular review and update of statistics to maintain accuracy
