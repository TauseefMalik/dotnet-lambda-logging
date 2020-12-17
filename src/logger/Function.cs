
using System.Threading.Tasks;
using Amazon.Lambda.Core;
using Amazon.Lambda.SQSEvents;
using AWS.Logger;
using AWS.Logger.SeriLog;
using Serilog;
using Serilog.Context;
using Serilog.Core;
using Serilog.Events;
using Serilog.Formatting;
using Serilog.Formatting.Compact;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly : LambdaSerializer (typeof (Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace logger {
    public class Function {
        /// <summary>
        /// Default constructor. This constructor is used by Lambda to construct the instance. When invoked in a Lambda environment
        /// the AWS credentials will come from the IAM role associated with the function and the AWS region will be set to the
        /// region the Lambda function is executed in.
        /// </summary>

        public Function () { }

        /// <summary>
        /// This method is called for every Lambda invocation. This method takes in an SQS event object and can be used 
        /// to respond to SQS messages.
        /// </summary>
        /// <param name="evnt"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task FunctionHandler (SQSEvent evnt, ILambdaContext context) {
            context.Logger.LogLine ($"Processed message using Serilog/Nlog");
            var levelSwitch = new LoggingLevelSwitch ();
            levelSwitch.MinimumLevel = LogEventLevel.Warning;
            var logger = new LoggerConfiguration ().Enrich.FromLogContext ()
                .MinimumLevel.ControlledBy (levelSwitch).WriteTo.Console (new RenderedCompactJsonFormatter ()).CreateLogger ();

            using (LogContext.PushProperty ("level", "debug")) {
                logger.Debug ("This is a debug level message");
            }
            using (LogContext.PushProperty ("level", "info")) {
                logger.Information ("This is a info level message");
            }
            using (LogContext.PushProperty ("level", "warning")) {
                logger.Warning ("This is a warning level message");
            }
            using (LogContext.PushProperty ("level", "error")) {
                logger.Error ("Serilog Check the AWS Console CloudWatch Logs console");
            }
            // TODO: Do interesting work based on the new message
            await Task.CompletedTask;
        }
    }
}