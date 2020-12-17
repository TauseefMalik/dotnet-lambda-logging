#!/bin/bash
#./build <BUILD-STAGE> <LOG-LEVEL> <function Name> <S3 Bucket TO PACKCAGE LAMBDA>
if [ "$1" != "Test" ] && [ "$1" != "Prod" ] && [ "$1" != "Dev" ]; then
   echo "You must set Test or Prod or Dev as arg."
   exit 1
fi
if [ "$2" != "INFO" ] && [ "$2" != "ERROR" ] && [ "$2" != "WARNING" ] && [ "$2" != "DEBUG" ]; then
   echo "You must set log-level to either INFO, WARNING, ERROR OR DEBUG."
   exit 1
fi

ENV=$1
LOGLEVEL=$2
FUNCTION_NAME=$3

if [ $ENV == "Dev" ]; then
   AWS_DEFAULT_REGION="<>"
   S3_BUCKET="<>"
elif [ $ENV == "Test" ] || [ $ENV == "Prod" ]; then
   AWS_DEFAULT_REGION="<>"
   S3_BUCKET="<>"
fi

case $ENV in
   "Dev")
   ARN="<>"
   ;;
   "Test")
   ARN="<>"
   ;;
   "Prod")
   ARN="<>"
   ;;
   *)
esac

if [ $? -ne 0 ];then
   echo "dotnet installation failed."
   exit 1
fi

sed -i "s/{{ENV}}/$ENV/g" template.yaml
sed -i "s/{{LOGLEVEL}}/$LOGLEVEL/g" template.yaml
sed -i "s/{{ARN}}/$ARN/g" template.yaml
sed -i "s/{{REGION}}/$AWS_DEFAULT_REGION/g" template.yaml
# sam local invoke -t template.yaml -d 5890 --profile=<profile> -e event.json "LambdaFunction"
# #deploy
sam package --template-file template.yaml --s3-bucket $S3_BUCKET --output-template-file packaged.yaml
if [ $? -ne 0 ];then
   echo "sam package failed."
   exit 1
fi

if [ $ENV == "Dev" ]; then
   aws cloudformation deploy --template-file packaged.yaml --stack-name $FUNCTION_NAME$ENV --capabilities CAPABILITY_IAM \
   --role-arn <role-arn>
else
   aws cloudformation deploy --template-file packaged.yaml --stack-name $FUNCTION_NAME$ENV --capabilities CAPABILITY_IAM \
   --role-arn <role-arn>
fi

if [ $? -ne 0 ];then
  echo "cloudformation deploy failed."
  aws cloudformation describe-stack-events --stack-name $FUNCTION_NAME$ENV --max-items 5
  exit 1
fi

sed -i "s/$ENV/{{ENV}}/g" template.yaml
sed -i "s/$LOGLEVEL/{{LOGLEVEL}}/g" template.yaml
sed -i "s/$ARN/{{ARN}}/g" template.yaml
sed -i "s/$AWS_DEFAULT_REGION/{{REGION}}/g" template.yaml