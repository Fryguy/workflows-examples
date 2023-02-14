{
  "Comment": "Provision a VMware VM.",
  "StartAt": "CloneTemplate",
  "States": {
    "CloneTemplate": {
      "Type": "Task",
      "Resource": "docker://docker.io/agrare/clone-template:latest",
      "Next": "CheckTaskComplete",
      "Credentials": {
        "api_user": "$.api_user",
        "api_password": "$.api_password",
        "vcenter_user": "$.vcenter_user",
        "vcenter_password": "$.vcenter_password"
      },
      "Parameters": {
        "provider_id": "$.attrs.dialog_provider",
        "template": "$.attrs.dialog_source_template",
        "name": "$.attrs.dialog_vm_name"
      }
    },

    "CheckTaskComplete": {
      "Type": "Task",
      "Resource": "docker://docker.io/agrare/check-task-complete:latest",
      "Next": "PollTaskComplete",
      "Credentials": {
        "vcenter_user": "$.vcenter_user",
        "vcenter_password": "$.vcenter_password"
      },
      "Parameters": {
        "vcenter_host": "$.vcenter_host",
        "task": "$.task"
      }
    },

    "PollTaskComplete": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.state",
          "StringEquals": "success",
          "Next": "PowerOnVM"
        },
        {
          "Variable": "$.state",
          "StringEquals": "running",
          "Next": "RetryState"
        },
        {
          "Variable": "$.state",
          "StringEquals": "error",
          "Next": "FailState"
        }
      ],
      "Default": "FailState"
    },

    "RetryState": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckTaskComplete"
    },

    "PowerOnVM": {
      "Type": "Task",
      "Resource": "docker://docker.io/agrare/power-on-vm:latest",
      "Next": "SuccessState",
      "Credentials": {
        "vcenter_user": "$.vcenter_user",
        "vcenter_password": "$.vcenter_password"
      },
      "Parameters": {
        "vcenter_host": "$.vcenter_host",
        "vm": "$.vm"
      }
    },

    "FailState": {
      "Type": "Fail",
      "Error": "FailStateError",
      "Cause": "No Matches!"
    },

    "SuccessState": {
      "Type": "Succeed"
    }
  }
}
