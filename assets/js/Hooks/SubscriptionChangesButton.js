const SubscriptionChangesButton = {
    mounted() {
        // Get the parent form and the button
        const form = this.el.closest("form");
        const button = form.querySelector("#save-changes-button");
    
        // Initialize button state on mount
        this.updateButtonState(form, button); 
    
        // Listen for changes on the current checkbox
        this.el.addEventListener("change", () => {
          this.updateButtonState(form, button);
        });
      },
    
      updateButtonState(form, button) {
        // Get all checkbox inputs
        const inputs = form.querySelectorAll('input[type="checkbox"]');
    
        // Check if any input value differs from its original value
        const hasChanges = Array.from(inputs).some(input => {
          const originalValue = input.defaultChecked; // Tracks the initial checked state
          const currentValue = input.checked;
          return originalValue !== currentValue;
        });
    
        // Enable or disable the button based on changes
        button.disabled = !hasChanges;
      }
};

export default SubscriptionChangesButton;