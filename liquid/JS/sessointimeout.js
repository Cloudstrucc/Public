// inactivity-warning.js

class SessionManager {
    constructor(warningTime, countdownTime) {
        this.warningTime = warningTime * 60 * 1000; // Convert minutes to milliseconds
        this.countdownTime = countdownTime * 60 * 1000;
        this.warningTimer = null;
        this.countdownTimer = null;
        this.remainingTime = this.countdownTime;
        this.modal = null;
        this.countdownElement = null;
        
        this.setupModal();
        this.startWarningTimer();
        this.setupEventListeners();
    }

    setupModal() {
        // Create modal HTML
        const modalHtml = `
            <div id="inactivityModal" class="modal fade" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Session Timeout Warning</h5>
                        </div>
                        <div class="modal-body">
                            <p>Your session will expire in <span id="countdown">120</span> seconds due to inactivity.</p>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" id="continueSession">Continue Session</button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML('beforeend', modalHtml);
        this.modal = new bootstrap.Modal(document.getElementById('inactivityModal'));
        this.countdownElement = document.getElementById('countdown');
    }

    setupEventListeners() {
        // Reset timer on user activity
        const events = ['mousedown', 'mousemove', 'keydown', 'scroll', 'touchstart'];
        events.forEach(event => {
            document.addEventListener(event, () => this.resetWarningTimer());
        });

        // Continue session button handler
        document.getElementById('continueSession').addEventListener('click', () => {
            this.continueSession();
        });
    }

    startWarningTimer() {
        this.warningTimer = setTimeout(() => {
            this.showWarningModal();
        }, this.warningTime);
    }

    resetWarningTimer() {
        if (!this.modal._isShown) {
            clearTimeout(this.warningTimer);
            this.startWarningTimer();
        }
    }

    showWarningModal() {
        this.modal.show();
        this.remainingTime = this.countdownTime;
        this.startCountdown();
    }

    startCountdown() {
        const interval = 1000; // Update every second
        this.countdownTimer = setInterval(() => {
            this.remainingTime -= interval;
            const seconds = Math.ceil(this.remainingTime / 1000);
            this.countdownElement.textContent = seconds;

            if (this.remainingTime <= 0) {
                this.logout();
            }
        }, interval);
    }

    continueSession() {
        clearInterval(this.countdownTimer);
        this.modal.hide();
        this.resetWarningTimer();
        
        // Call endpoint to extend session
        fetch('/Account/ExtendSession', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'RequestVerificationToken': document.querySelector('input[name="__RequestVerificationToken"]').value
            }
        });
    }

    logout() {
        clearInterval(this.countdownTimer);
        window.location.href = '/Account/Logout';
    }
}