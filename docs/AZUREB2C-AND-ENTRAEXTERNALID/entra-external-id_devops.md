<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Elections Canada - Microsoft Entra External ID</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .infographic-container {
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        .header {
            background-color: #ffffff;
            padding: 20px;
            position: relative;
            border-bottom: 5px solid #c51f3f;
        }
        .title {
            color: #333;
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
        }
        .subtitle {
            color: #666;
            font-size: 20px;
            margin-top: 0;
        }
        .main-content {
            padding: 30px;
            position: relative;
        }
        .protected-b {
            position: absolute;
            top: 20px;
            right: 30px;
            background-color: #c51f3f;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 14px;
        }
        .architecture-diagram {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 20px 0 40px;
            position: relative;
        }
        .layer {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            z-index: 1;
            margin: 15px 0;
        }
        .connector {
            height: 60px;
            width: 4px;
            background-color: #202746;
            position: relative;
        }
        .connector::before,
        .connector::after {
            content: '';
            position: absolute;
            width: 12px;
            height: 12px;
            background-color: #202746;
            border-radius: 50%;
            left: 50%;
            transform: translateX(-50%);
        }
        .connector::before {
            top: -6px;
        }
        .connector::after {
            bottom: -6px;
        }
        .user-layer {
            background-color: #f0f5ff;
            border-radius: 12px;
            padding: 15px 30px;
            box-shadow: 0 4px 12px rgba(32,39,70,0.1);
        }
        .entra-layer {
            background-color: #e6f7ff;
            border-radius: 12px;
            padding: 20px 30px;
            box-shadow: 0 4px 12px rgba(32,39,70,0.2);
            border: 2px solid #202746;
            position: relative;
        }
        .internal-layer {
            background-color: #f0f5ff;
            border-radius: 12px;
            padding: 15px 30px;
            box-shadow: 0 4px 12px rgba(32,39,70,0.1);
        }
        .services-layer {
            background-color: #f0f5ff;
            border-radius: 12px;
            padding: 15px 30px;
            box-shadow: 0 4px 12px rgba(32,39,70,0.1);
        }
        .shield {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            border-radius: 12px;
            border: 3px solid #c51f3f;
            box-shadow: 0 0 30px rgba(197,31,63,0.2);
            pointer-events: none;
            z-index: -1;
        }
        .layer-title {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .icon-container {
            display: flex;
            gap: 25px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .icon-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        .icon {
            width: 36px;
            height: 36px;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 8px;
        }
        .icon-label {
            font-size: 12px;
            text-align: center;
            color: #555;
        }
        .security-features {
            display: flex;
            justify-content: space-around;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        .feature {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100px;
            margin: 10px;
        }
        .feature-icon {
            width: 50px;
            height: 50px;
            background-color: #f5f5f5;
            border-radius: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .feature-label {
            text-align: center;
            font-size: 12px;
            color: #333;
        }
        .elections-emblem {
            position: absolute;
            opacity: 0.05;
            width: 300px;
            height: auto;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: -1;
        }
        .footer {
            background-color: #f0f5ff;
            padding: 15px 30px;
            text-align: center;
            font-size: 14px;
            color: #555;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="infographic-container">
        <div class="header">
            <h1 class="title">MICROSOFT ENTRA EXTERNAL ID</h1>
            <p class="subtitle">Secure Identity Management for Elections Canada</p>
        </div>
        <div class="main-content">
            <div class="protected-b">PBMM Guide</div>
            <svg class="elections-emblem" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100">
                <path fill="#c51f3f" d="M65.5,32.5c0,0.3-0.2,0.5-0.5,0.5H50c-0.3,0-0.5-0.2-0.5-0.5v-15C49.5,17.2,49.7,17,50,17H65c0.3,0,0.5,0.2,0.5,0.5 V32.5z"/>
                <path fill="#c51f3f" d="M90.5,32.5c0,0.3-0.2,0.5-0.5,0.5H75c-0.3,0-0.5-0.2-0.5-0.5v-15C74.5,17.2,74.7,17,75,17H90c0.3,0,0.5,0.2,0.5,0.5 V32.5z"/>
                <path fill="#c51f3f" d="M115.5,32.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V32.5z"/>
                <path fill="#c51f3f" d="M140.5,32.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V32.5z"/>
                <path fill="#c51f3f" d="M40.5,57.5c0,0.3-0.2,0.5-0.5,0.5H25c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M65.5,57.5c0,0.3-0.2,0.5-0.5,0.5H50c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5H65c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M90.5,57.5c0,0.3-0.2,0.5-0.5,0.5H75c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5H90c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M115.5,57.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M140.5,57.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M165.5,57.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V57.5z"/>
                <path fill="#c51f3f" d="M65.5,82.5c0,0.3-0.2,0.5-0.5,0.5H50c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5H65c0.3,0,0.5,0.2,0.5,0.5 V82.5z"/>
                <path fill="#c51f3f" d="M90.5,82.5c0,0.3-0.2,0.5-0.5,0.5H75c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5H90c0.3,0,0.5,0.2,0.5,0.5 V82.5z"/>
                <path fill="#c51f3f" d="M115.5,82.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V82.5z"/>
                <path fill="#c51f3f" d="M140.5,82.5c0,0.3-0.2,0.5-0.5,0.5h-15c-0.3,0-0.5-0.2-0.5-0.5v-15c0-0.3,0.2-0.5,0.5-0.5h15c0.3,0,0.5,0.2,0.5,0.5 V82.5z"/>
            </svg>
            <div class="architecture-diagram">
                <div class="layer user-layer">
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#202746" d="M12,12A6,6 0 0,0 18,6C18,2.68 15.31,0 12,0C8.68,0 6,2.68 6,6A6,6 0 0,0 12,12M12,14C7.58,14 4,15.79 4,18V20H20V18C20,15.79 16.42,14 12,14Z"/>
                        </svg>
                        EXTERNAL USERS
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,4A4,4 0 0,1 16,8A4,4 0 0,1 12,12A4,4 0 0,1 8,8A4,4 0 0,1 12,4M12,14C16.42,14 20,15.79 20,18V20H4V18C4,15.79 7.58,14 12,14Z" />
                            </svg>
                            <div class="icon-label">Citizens</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,5A3.5,3.5 0 0,0 8.5,8.5A3.5,3.5 0 0,0 12,12A3.5,3.5 0 0,0 15.5,8.5A3.5,3.5 0 0,0 12,5M12,7A1.5,1.5 0 0,1 13.5,8.5A1.5,1.5 0 0,1 12,10A1.5,1.5 0 0,1 10.5,8.5A1.5,1.5 0 0,1 12,7M5.5,8A2.5,2.5 0 0,0 3,10.5C3,11.44 3.53,12.25 4.29,12.68C4.65,12.88 5.06,13 5.5,13C5.94,13 6.35,12.88 6.71,12.68C7.08,12.47 7.39,12.17 7.62,11.81C6.89,10.86 6.5,9.7 6.5,8.5C6.5,8.41 6.5,8.31 6.5,8.22C6.2,8.08 5.86,8 5.5,8M18.5,8C18.14,8 17.8,8.08 17.5,8.22C17.5,8.31 17.5,8.41 17.5,8.5C17.5,9.7 17.11,10.86 16.38,11.81C16.5,12 16.63,12.15 16.78,12.3C16.94,12.45 17.1,12.58 17.29,12.68C17.65,12.88 18.06,13 18.5,13C18.94,13 19.35,12.88 19.71,12.68C20.47,12.25 21,11.44 21,10.5A2.5,2.5 0 0,0 18.5,8M12,14C9.66,14 5,15.17 5,17.5V19H19V17.5C19,15.17 14.34,14 12,14M4.71,14.55C2.78,14.78 0,15.76 0,17.5V19H3V17.07C3,16.06 3.69,15.22 4.71,14.55M19.29,14.55C20.31,15.22 21,16.06 21,17.07V19H24V17.5C24,15.76 21.22,14.78 19.29,14.55M12,16C13.53,16 15.24,16.5 16.23,17H7.77C8.76,16.5 10.47,16 12,16Z" />
                            </svg>
                            <div class="icon-label">Political Parties</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M16,9C18.33,9 23,10.17 23,12.5V15H17V12.5C17,11 16.19,9.89 15.04,9.05L16,9M8,9C10.33,9 15,10.17 15,12.5V15H1V12.5C1,10.17 5.67,9 8,9M8,7A3,3 0 0,1 5,4A3,3 0 0,1 8,1A3,3 0 0,1 11,4A3,3 0 0,1 8,7M16,7A3,3 0 0,1 13,4A3,3 0 0,1 16,1A3,3 0 0,1 19,4A3,3 0 0,1 16,7Z" />
                            </svg>
                            <div class="icon-label">Electoral Partners</div>
                        </div>
                    </div>
                </div>
                <div class="connector"></div>
                <div class="layer entra-layer">
                    <div class="shield"></div>
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="32" height="32">
                            <path fill="#202746" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,7C13.4,7 14.8,8.1 14.8,9.5V11C15.4,11 16,11.6 16,12.3V15.8C16,16.4 15.4,17 14.7,17H9.2C8.6,17 8,16.4 8,15.7V12.2C8,11.6 8.6,11 9.2,11V9.5C9.2,8.1 10.6,7 12,7M12,8.2C11.2,8.2 10.5,8.7 10.5,9.5V11H13.5V9.5C13.5,8.7 12.8,8.2 12,8.2Z" />
                        </svg>
                        MICROSOFT ENTRA EXTERNAL ID
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#202746" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5M17,17.25C17,14.87 14.87,13 12,13C9.13,13 7,14.87 7,17.25V20H17V17.25Z" />
                            </svg>
                            <div class="icon-label">User Flows</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#202746" d="M10,17L6,13L7.41,11.59L10,14.17L16.59,7.58L18,9M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1Z" />
                            </svg>
                            <div class="icon-label">Authentication</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#202746" d="M14,2A8,8 0 0,0 6,10A8,8 0 0,0 14,18A8,8 0 0,0 22,10A8,8 0 0,0 14,2M4.93,5.82C3.08,7.34 2,9.61 2,12A8,8 0 0,0 10,20C10.64,20 11.27,19.92 11.88,19.77C10.12,19.38 8.5,18.5 7.17,17.29C5.22,16.25 4,14.21 4,12C4,11.7 4.03,11.41 4.07,11.11C4.03,10.74 4,10.37 4,10C4,8.56 4.32,7.13 4.93,5.82Z" />
                            </svg>
                            <div class="icon-label">Bilingual Support</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#202746" d="M12,2A9,9 0 0,0 3,11C3,14.03 4.53,16.82 7,18.47V22H9V19H11V22H13V19H15V22H17V18.46C19.47,16.81 21,14 21,11A9,9 0 0,0 12,2M8,11A2,2 0 0,1 10,13A2,2 0 0,1 8,15A2,2 0 0,1 6,13A2,2 0 0,1 8,11M16,11A2,2 0 0,1 18,13A2,2 0 0,1 16,15A2,2 0 0,1 14,13A2,2 0 0,1 16,11M12,14L13.5,17H10.5L12,14Z" />
                            </svg>
                            <div class="icon-label">Token Management</div>
                        </div>
                    </div>
                </div>
                <div class="connector"></div>
                <div class="layer internal-layer">
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#202746" d="M12,5.5A3.5,3.5 0 0,1 15.5,9A3.5,3.5 0 0,1 12,12.5A3.5,3.5 0 0,1 8.5,9A3.5,3.5 0 0,1 12,5.5M5,8C5.56,8 6.08,8.15 6.53,8.42C6.38,9.85 6.8,11.27 7.66,12.38C7.16,13.34 6.16,14 5,14A3,3 0 0,1 2,11A3,3 0 0,1 5,8M19,8A3,3 0 0,1 22,11A3,3 0 0,1 19,14C17.84,14 16.84,13.34 16.34,12.38C17.2,11.27 17.62,9.85 17.47,8.42C17.92,8.15 18.44,8 19,8M5.5,18.25C5.5,16.18 8.41,14.5 12,14.5C15.59,14.5 18.5,16.18 18.5,18.25V20H5.5V18.25M0,20V18.5C0,17.11 1.89,15.94 4.45,15.6C3.86,16.28 3.5,17.22 3.5,18.25V20H0M24,20H20.5V18.25C20.5,17.22 20.14,16.28 19.55,15.6C22.11,15.94 24,17.11 24,18.5V20Z" />
                        </svg>
                        INTERNAL STAFF
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5M17,17.25C17,14.87 14.87,13 12,13C9.13,13 7,14.87 7,17.25V20H17V17.25Z" />
                            </svg>
                            <div class="icon-label">IT Administrators</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M10,2H14A2,2 0 0,1 16,4V6H20A2,2 0 0,1 22,8V19A2,2 0 0,1 20,21H4C2.89,21 2,20.1 2,19V8C2,6.89 2.89,6 4,6H8V4C8,2.89 8.89,2 10,2M14,6V4H10V6H14Z" />
                            </svg>
                            <div class="icon-label">Security Team</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M20 2H4C2.9 2 2 2.9 2 4V22L6 18H20C21.1 18 22 17.1 22 16V4C22 2.9 21.1 2 20 2M20 16H5.2L4 17.2V4H20V16Z" />
                            </svg>
                            <div class="icon-label">Help Desk</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12 5.5A3.5 3.5 0 0 1 15.5 9A3.5 3.5 0 0 1 12 12.5A3.5 3.5 0 0 1 8.5 9A3.5 3.5 0 0 1 12 5.5M5 8C5.56 8 6.08 8.15 6.53 8.42C6.38 9.85 6.8 11.27 7.66 12.38C7.16 13.34 6.16 14 5 14A3 3 0 0 1 2 11A3 3 0 0 1 5 8M19 8A3 3 0 0 1 22 11A3 3 0 0 1 19 14C17.84 14 16.84 13.34 1 19 14C17.84 14 16.84 13.34 16.34 12.38C17.2 11.27 17.62 9.85 17.47 8.42C17.92 8.15 18.44 8 19 8M5.5 18.25C5.5 16.18 8.41 14.5 12 14.5C15.59 14.5 18.5 16.18 18.5 18.25V20H5.5V18.25M0 20V18.5C0 17.11 1.89 15.94 4.45 15.6C3.86 16.28 3.5 17.22 3.5 18.25V20H0M24 20H20.5V18.25C20.5 17.22 20.14 16.28 19.55 15.6C22.11 15.94 24 17.11 24 18.5V20Z" />
                            </svg>
                            <div class="icon-label">Electoral Officials</div>
                        </div>
                    </div>
                </div>
                <div class="connector"></div>
                <div class="layer services-layer">
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#202746" d="M21,16.5C21,16.88 20.79,17.21 20.47,17.38L12.57,21.82C12.41,21.94 12.21,22 12,22C11.79,22 11.59,21.94 11.43,21.82L3.53,17.38C3.21,17.21 3,16.88 3,16.5V7.5C3,7.12 3.21,6.79 3.53,6.62L11.43,2.18C11.59,2.06 11.79,2 12,2C12.21,2 12.41,2.06 12.57,2.18L20.47,6.62C20.79,6.79 21,7.12 21,7.5V16.5M12,4.15L6.04,7.5L12,10.85L17.96,7.5L12,4.15M5,15.91L11,19.29V12.58L5,9.21V15.91M19,15.91V9.21L13,12.58V19.29L19,15.91Z" />
                        </svg>
                        PROTECTED APPLICATIONS
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,17.56L16.07,16.43L16.62,10.33H9.38L9.2,8.3H16.8L17,6.31H7L7.56,12.32H14.45L14.22,14.9L12,15.5L9.78,14.9L9.64,13.24H7.64L7.93,16.43L12,17.56M4.07,3H19.93L18.5,19.2L12,21L5.5,19.2L4.07,3Z" />
                            </svg>
                            <div class="icon-label">Web Applications</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M21,17H7V3H21M21,1H7A2,2 0 0,0 5,3V17A2,2 0 0,0 7,19H21A2,2 0 0,0 23,17V3A2,2 0 0,0 21,1M3,5H1V21A2,2 0 0,0 3,23H19V21H3M15.96,10.29L13.21,13.83L11.25,11.47L8.5,15H19.5L15.96,10.29Z" />
                            </svg>
                            <div class="icon-label">Portal Services</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M7,2H17A2,2 0 0,1 19,4V20A2,2 0 0,1 17,22H7A2,2 0 0,1 5,20V4A2,2 0 0,1 7,2M7,4V8H17V4H7M7,10V12H9V10H7M11,10V12H13V10H11M15,10V12H17V10H15M7,14V16H9V14H7M11,14V16H13V14H11M15,14V16H17V14H15M7,18V20H9V18H7M11,18V20H13V18H11M15,18V20H17V18H15Z" />
                            </svg>
                            <div class="icon-label">Secure APIs</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M19,8H5V19H19V8M19,3H18V1H16V3H8V1H6V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5A2,2 0 0,0 19,3M16.53,11.06L15.47,10L10.59,14.88L8.47,12.76L7.41,13.82L10.59,17L16.53,11.06Z" />
                            </svg>
                            <div class="icon-label">Electoral Systems</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="security-features">
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#c51f3f" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5Z" />
                        </svg>
                    </div>
                    <div class="feature-label">PBMM Compliant</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#c51f3f" d="M10,16V15H8V13H10V12H8V10H10V8H12V10H14V8H16V10H14V12H16V13H14V15H16V16H14V18H16V20H14A2,2 0 0,1 12,22A2,2 0 0,1 10,20H8V18H10V16M12,2A5,5 0 0,1 17,7V13L19,15V17H17V14L15,12V7A3,3 0 0,0 12,4A3,3 0 0,0 9,7V12L7,14V17H5V15L7,13V7A5,5 0 0,1 12,2Z" />
                        </svg>
                    </div>
                    <div class="feature-label">ITSG-33 Compliant</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#c51f3f" d="M12,2A9,9 0 0,0 3,11C3,14.03 4.53,16.82 7,18.47V22H9V19H11V22H13V19H15V22H17V18.46C19.47,16.81 21,14 21,11A9,9 0 0,0 12,2M8,11A2,2 0 0,1 10,13A2,2 0 0,1 8,15A2,2 0 0,1 6,13A2,2 0 0,1 8,11M16,11A2,2 0 0,1 18,13A2,2 0 0,1 16,15A2,2 0 0,1 14,13A2,2 0 0,1 16,11M12,14L13.5,17H10.5L12,14Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Multi-Factor Authentication</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#c51f3f" d="M14,2A8,8 0 0,0 6,10A8,8 0 0,0 14,18A8,8 0 0,0 22,10A8,8 0 0,0 14,2M4.93,5.82C3.08,7.34 2,9.61 2,12A8,8 0 0,0 10,20C10.64,20 11.27,19.92 11.88,19.77C10.12,19.38 8.5,18.5 7.17,17.29C5.22,16.25 4,14.21 4,12C4,11.7 4.03,11.41 4.07,11.11C4.03,10.74 4,10.37 4,10C4,8.56 4.32,7.13 4.93,5.82Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Bilingual Support</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#c51f3f" d="M12,3C7.58,3 4,4.79 4,7C4,9.21 7.58,11 12,11C16.42,11 20,9.21 20,7C20,4.79 16.42,3 12,3M4,9V12C4,14.21 7.58,16 12,16C16.42,16 20,14.21 20,12V9C20,11.21 16.42,13 12,13C7.58,13 4,11.21 4,9M4,14V17C4,19.21 7.58,21 12,21C16.42,21 20,19.21 20,17V14C20,16.21 16.42,18 12,18C7.58,18 4,16.21 4,14Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Centralized User Storage</div>
                </div>
            </div>
        </div>
        <div class="footer">
            Elections Canada | Microsoft Entra External ID | Protected B | April 2025
        </div>
    </div>
</body>
</html>                                

## Overview

Elections Canada requires a secure identity solution that allows external users to access specific applications while maintaining strict security standards mandated by federal regulations. This document describes the implementation of Microsoft Entra External ID (formerly Azure AD B2C) for managing external identities.

:::mermaid
graph TD
    A[External User] -->|Authentication Request| B[Application Portal]
    B -->|Redirect to Identity Provider| C[Microsoft Entra External ID]
    C -->|User Authentication| D{Authentication Type}
    D -->|Social Identity| E[Social Identity Provider]
    D -->|Local Account| G[Entra External ID Store]
    E -->|Authentication Response| C
    G -->|Authentication Response| C
    C -->|Token Issuance| B
    B -->|Access Granted| H[Protected Applications]
  
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style H fill:#bbf,stroke:#333,stroke-width:2px
:::

## Key Components

### 1. Microsoft Entra External ID Tenant

Elections Canada utilizes a dedicated Microsoft Entra External ID tenant (`electcan2.onmicrosoft.com`) for managing external identities. This tenant is separate from the organizational Entra ID used for internal staff.

### 2. User Flows

The implementation uses the standard "Sign up and sign in" user flow that facilitates the external client authentication process:

:::mermaid
graph LR
    A[External User] --> B[Sign Up and Sign In User Flow]
    B --> C[Email Verification]
    C --> D[Credential Creation/Validation]
    D --> E[Claims Collection]
    E --> F[Application Access]
:::

#### Sign Up and Sign In User Flow

- Email and password authentication
- Email-based verification during registration
- Collection of key user attributes:
  - Email address
  - First name
  - Last name
  - Phone number
- Multi-factor authentication via email for sensitive operations
- Bilingual support (English and French)

### 3. Identity Provider Configuration

Elections Canada's implementation uses the default local account identity provider to manage external client accounts:

:::mermaid
graph TD
    A[Authentication Request] --> B[Entra External ID]
    B --> C[Local Account Provider]
    C --> D[Token Issuance]
    D --> E[Application Access]
:::

The following identity provider configuration is used:

- **Local Accounts**: Email and password based accounts in the Entra External ID identity store
- Self-service password reset
- Email verification
- Progressive profiling capabilities

## Technical Implementation

### Architecture

:::mermaid
graph TB
    A[User Browser] -->|1. Access Request| B[Application Portal]
    B -->|2. Auth Redirect| C[Microsoft Entra External ID]
    C -->|3. Authentication| D[Identity Provider]
    D -->|4. Token| C
    C -->|5. Token Issuance| B
    B -->|6. API Call with Token| E[Protected API]
    E -->|7. Token Validation| F[Microsoft Entra ID]
  
    subgraph "Azure"
    C
    F
    end
  
    subgraph "Organizational Infrastructure"
    B
    E
    G[Database]
    end
  
    E --> G
:::

### Protocol Support

The Entra External ID tenant supports industry-standard authentication protocols for application integration:

:::mermaid
graph TD
    A[Integration Protocols] --> B[OpenID Connect]
    A --> C[SAML 2.0]
  
    B --> D[Authorization Code Flow]
    B --> E[Implicit Flow]
    B --> F[Hybrid Flow]
  
    C --> G[SP-Initiated SSO]
    C --> H[IdP-Initiated SSO]
  
    D --> I[Application Integration]
    E --> I
    F --> I
    G --> I
    H --> I
:::

#### OpenID Connect (OIDC) Benefits

- Modern, REST-based protocol
- Simplified token handling
- Mobile application support
- User info endpoint for attribute retrieval
- Lightweight implementation

#### SAML Benefits

- Widespread enterprise application support
- Rich attribute statements
- Mature implementation patterns
- Legacy application compatibility

### Data Flow

The authentication process follows these steps:

1. User attempts to access application
2. User is redirected to Entra External ID for authentication
3. User authenticates via local account
4. Entra External ID issues a token containing claims about the user
5. The application validates the token and extracts user information
6. Access is granted based on user claims and application permissions

### Security Controls

The following security controls have been implemented:

:::mermaid
graph TD
    A[Security Controls] --> B[Authentication Policies]
    A --> C[Token Handling]
    A --> D[Data Protection]
    A --> E[Monitoring]
  
    B --> B1[MFA Requirements]
    B --> B2[Password Policies]
    B --> B3[Session Management]
  
    C --> C1[Token Encryption]
    C --> C2[Signature Validation]
    C --> C3[Lifetime Policies]
  
    D --> D1[Data Encryption]
    D --> D2[Personal Info Handling]
    D --> D3[Consent Management]
  
    E --> E1[Logging]
    E --> E2[Alerting]
    E --> E3[Reporting]
:::

#### Authentication Policies

- Strong password requirements (12+ characters, complexity)
- Multi-factor authentication via email for sensitive operations
- Session timeout after 30 minutes of inactivity

#### Token Security

- JWT tokens with industry-standard encryption
- Configurable token lifetimes
- Refresh token patterns
- Audience and issuer validation

#### Data Protection

- Encryption of all personal data at rest and in transit
- Minimal data collection in accordance with Privacy Act
- Automated data retention policies
- Strict data classification

## Application Integration

### Single Sign-On Benefits

The implementation of Entra External ID provides the following SSO benefits:

- **Improved User Experience**: Users sign in once and access multiple applications
- **Reduced Password Fatigue**: Eliminating multiple credentials for different applications
- **Centralized Access Control**: Manage permissions from a single location
- **Consistent Security Policies**: Apply uniform security controls across applications
- **Simplified Onboarding/Offboarding**: Streamlined user lifecycle management
- **Enhanced Security Monitoring**: Consolidated authentication logging

### Authentication Flow

The following diagram shows how applications integrate with Entra ID:

:::mermaid
sequenceDiagram
    participant User
    participant App as Application
    participant Auth as Entra External ID
    participant API as Protected API
  
    User->>App: Access Request
    App->>Auth: Redirect to Authentication
    Auth->>User: Authentication Prompt
    User->>Auth: Provide Credentials
    Auth->>User: Email MFA (if required)
    User->>Auth: Complete MFA
    Auth->>App: Issue ID Token + Access Token
    App->>API: API Request with Access Token
    API->>API: Validate Token
    API->>App: API Response
    App->>User: Display Protected Content
:::

### Token Claims

The token issued to applications contains the following claims:

- Standard claims:
  - `sub`: Unique identifier for the user
  - `email`: User's email address
  - `given_name`: User's first name
  - `family_name`: User's last name
  - `phone_number`: User's phone number
  - `iat`: Time at which the token was issued
  - `exp`: Expiration time

## Operational Considerations

### Custom Domain Configuration

The current Entra External ID tenant uses the default domain `electcan2.onmicrosoft.com`. To configure a custom domain (e.g., `login.elections.ca`):

:::mermaid
graph TD
    A[Custom Domain Configuration] --> B[Purchase Domain]
    B --> C[Verify Domain Ownership]
    C --> D[Configure DNS Records]
    D --> E[Add Custom Domain in Entra ID]
    E --> F[Configure User Flows]
    F --> G[Update Applications]
  
    C --> C1[Add TXT Record]
    D --> D1[Add CNAME Record]
    D --> D2[Configure SSL Certificate]
:::

1. **Verify Domain Ownership**:

   - Add a TXT record to your DNS configuration
   - Microsoft will verify ownership through DNS lookup
2. **Configure DNS Records**:

   - Add a CNAME record pointing to `electcan2.b2clogin.com`
   - Configure SSL certificates if needed
3. **Add Custom Domain in Entra ID**:

   - Navigate to Entra External ID > Custom Domains
   - Add the verified domain
   - Set as primary domain if desired
4. **Update Applications**:

   - Update all application configurations to use the new domain
   - Test SSO flows with the custom domain

### Language Support

Entra External ID provides built-in support for both English and French:

:::mermaid
graph TD
    A[Language Configuration] --> B[User Flow Setup]
    B --> C[UI Customization]
    C --> D[Testing]
  
    B --> B1[Enable Languages]
    B --> B2[Set Default Language]
  
    C --> C1[Email Templates]
    C --> C2[Page UI Elements]
    C --> C3[Error Messages]
:::

1. **Enable Language Support**:

   - In the user flow properties, enable both English and French
   - Set the default fallback language (typically English)
   - Configure language detection mechanisms
2. **UI Customization**:

   - Create language-specific versions of all UI elements
   - Upload translated versions of:
     - Page content
     - Error messages
     - Email templates
3. **Language Selection**:

   - Add language selector in the user interface
   - Honor browser language preferences
   - Allow users to change language during the authentication process
4. **Testing**:

   - Test the complete user journey in both languages
   - Verify all email communications
   - Ensure accessibility standards are met in both languages

### Monitoring and Reporting

Comprehensive monitoring is implemented using Microsoft's built-in tools:

:::mermaid
graph LR
    A[Monitoring Tools] --> B[Microsoft Purview]
    A --> C[Entra ID Insights]
    A --> D[Azure Monitor]
    A --> E[Log Analytics]
  
    B --> B1[Data Governance]
    B --> B2[Compliance Reporting]
  
    C --> C1[Usage Patterns]
    C --> C2[Risk Detections]
    C --> C3[User Behavior]
  
    D --> D1[Performance Metrics]
    D --> D2[Health Status]
  
    E --> E1[Query Logs]
    E --> E2[Custom Dashboards]
    E --> E3[Alert Rules]
:::

#### Microsoft Purview

- Data discovery and classification
- Sensitive information monitoring
- Compliance reporting
- Risk assessment

#### Entra ID Insights

- Sign-in activity monitoring
- User risk detection
- Authentication method usage
- Self-service adoption metrics
- Conditional access impact

#### Azure Monitor

- Performance metrics
- Service health
- Resource utilization
- Availability monitoring

#### Log Analytics

- Custom query capabilities
- Long-term log retention
- Cross-service correlation
- Custom alert rules
- Visualization dashboards

#### Key Metrics Monitored

- Authentication success/failure rates
- Account lockouts
- Password reset volumes
- MFA enrollments and usage
- Geographic access patterns
- Suspicious activities
- API access patterns
- User flow completion rates

### User Management

Administrators can manage external users through:

1. Microsoft Entra Admin Portal
2. Microsoft Graph API integration
3. Role-based access control

## Compliance

The implementation adheres to:

- Treasury Board of Canada Secretariat (TBS) security standards
- Privacy Act requirements
- Elections Canada Act provisions
- ITSG-33 security controls
- Government of Canada Cloud Security Profile

## Roadmap

The following future enhancements may be considered for the identity system:

**Disclaimer**: The items listed below are recommendations and may or may not be pursued depending on organizational willingness and budget considerations.

- Enhanced identity verification capabilities
- Expanded multi-factor authentication options
- Additional identity provider integrations
- Implementation of verifiable credentials
- Risk-based authentication policies

## References

- [Microsoft Entra External ID Documentation](https://learn.microsoft.com/en-us/entra/external-id/)
- [Microsoft Entra Monitoring and Reporting](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/)
- [Microsoft Purview Documentation](https://learn.microsoft.com/en-us/purview/)
- [Government of Canada Identity and Access Management Guidelines](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/identity-management.html)
- [Treasury Board Identity Management Policy](https://www.tbs-sct.canada.ca/pol/doc-eng.aspx?id=16577)
- [OIDC Protocol Documentation](https://openid.net/connect/)
- [SAML 2.0 Technical Overview](http://docs.oasis-open.org/security/saml/Post2.0/sstc-saml-tech-overview-2.0.html)
